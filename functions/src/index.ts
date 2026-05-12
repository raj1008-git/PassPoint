// functions/src/index.ts
//
// CHANGES FROM ORIGINAL:
//   REMOVED: deactivateResignedStaff (scheduled)
//   ADDED:   syncEmployeesToFirestore (scheduled) — merges employee sync +
//            resigned staff deactivation into one daily function
//   ADDED:   generateAndEmailQr (onCall) — generates QR PNG, uploads to
//            Firebase Storage, emails invitee via SMTP
//   ADDED:   sendBulkQrEmails (onCall) — calls generateAndEmailQr logic
//            for all pending invites in an event
//   KEPT:    sendOtp, verifyOtp — byte-for-byte identical

import { onSchedule } from "firebase-functions/v2/scheduler";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import * as logger from "firebase-functions/logger";
import * as nodemailer from "nodemailer";
import * as QRCode from "qrcode";
import { v4 as uuidv4 } from "uuid";

// ---------------------------------------------------------------------------
// Firebase Admin init
// ---------------------------------------------------------------------------
initializeApp();

// ---------------------------------------------------------------------------
// SMTP Transporter — Office365 (UNCHANGED)
// ---------------------------------------------------------------------------
const transporter = nodemailer.createTransport({
  host: "mail.pmlil.com",
  port: 587,
  secure: false,
  auth: {
    user: "passpoint@pmlil.com",
    pass: "fm?$K6pK[2Co7^lD",
  },
  tls: { rejectUnauthorized: false },
});

// ---------------------------------------------------------------------------
// API Config (UNCHANGED)
// ---------------------------------------------------------------------------
const API_BASE_URL = "https://api.pmlil.com";
const API_USERNAME = "PMLI_INTERNAL";
const API_PASSWORD = "a8pP9{(992c}";
const INVALID_PHONES = new Set(["9800000000", "9700000000"]);

// HQ branch codes — map to KAMALADI
const HQ_BRANCH_CODES = new Set(["300", "301", "900"]);

// ---------------------------------------------------------------------------
// Helper — generate 6-digit OTP (UNCHANGED)
// ---------------------------------------------------------------------------
function generateOtp(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// ---------------------------------------------------------------------------
// Helper — fetch JWT token from PMLIL API (UNCHANGED logic)
// ---------------------------------------------------------------------------
async function getApiToken(): Promise<string> {
  const response = await fetch(`${API_BASE_URL}/api/Auth/token`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ userName: API_USERNAME, password: API_PASSWORD }),
  });

  if (!response.ok) {
    throw new Error(`Token fetch failed: ${response.status}`);
  }

  const data = await response.json() as { tokenString: string };
  return data.tokenString;
}

// ---------------------------------------------------------------------------
// Helper — filter predicate (same rules as existing StaffSyncService)
// ---------------------------------------------------------------------------
function passesFilter(user: {
  mobileNo: string;
  email: string;
  fullName: string;
  branchCode: string;
}): boolean {
  const phone = (user.mobileNo ?? "").trim();
  const email = (user.email ?? "").toLowerCase().trim();
  const name = (user.fullName ?? "").trim();

  if (!email.endsWith("@pmlil.com")) return false;
  if (!phone || phone.length < 7) return false;
  if (INVALID_PHONES.has(phone)) return false;
  if (name === name.toUpperCase() && name.length <= 20) return false;

  return true;
}

// ---------------------------------------------------------------------------
// Helper — fetch ALL active staff from API (paginated, returns full list)
// ---------------------------------------------------------------------------
interface ApiUser {
  rowId: string;
  fullName: string;
  branchCode: string;
  branchName: string;
  mobileNo: string;
  email: string;
  departmentName: string;
  provinceName: string;
}

async function fetchAllActiveStaff(): Promise<ApiUser[]> {
  const token = await getApiToken();
  const allUsers: ApiUser[] = [];
  const pageSize = 100;
  let start = 0;

  while (true) {
    const response = await fetch(
      `${API_BASE_URL}/api/OnlineUserServices/GetUserDetails?status=A`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          displayLength: pageSize,
          displayStart: start,
          status: "A",
        }),
      }
    );

    if (!response.ok) {
      throw new Error(`Staff fetch failed: ${response.status}`);
    }

    const data = await response.json() as {
      userList: ApiUser[];
      totalRecords: number;
    };

    const userList = data.userList ?? [];
    allUsers.push(...userList);

    start += pageSize;
    if (start >= data.totalRecords || userList.length < pageSize) break;
  }

  logger.info(`fetchAllActiveStaff: fetched ${allUsers.length} total records`);
  return allUsers;
}

// ---------------------------------------------------------------------------
// HTTPS Callable: sendOtp — UNCHANGED
// ---------------------------------------------------------------------------
export const sendOtp = onCall(
  { region: "asia-south1" },
  async (request) => {
    const { phone, email, name } = request.data as {
      phone: string;
      email: string;
      name: string;
    };

    if (!phone || !email || !name) {
      throw new HttpsError("invalid-argument", "phone, email, and name are required.");
    }
    if (!email.endsWith("@pmlil.com")) {
      throw new HttpsError("invalid-argument", "Email must be a pmlil.com address.");
    }

    const db = getFirestore();
    const otp = generateOtp();
    const expiresAt = Timestamp.fromMillis(Date.now() + 5 * 60 * 1000);

    await db.collection("otpVerifications").doc(phone).set({
      code: otp,
      email: email.toLowerCase().trim(),
      name: name.trim(),
      expiresAt,
      createdAt: Timestamp.now(),
    });

    const firstName = name.trim().split(" ")[0];
    await transporter.sendMail({
      from: '"PassPoint System" <passpoint@pmlil.com>',
      to: email.trim(),
      subject: `Your PassPoint verification code: ${otp}`,
      text: [
        `Hello ${firstName},`,
        ``,
        `Your PassPoint verification code is: ${otp}`,
        ``,
        `This code will expire in 5 minutes.`,
        ``,
        `If you did not request this, please ignore this email.`,
        ``,
        `— PassPoint, PMLIL`,
      ].join("\n"),
    });

    logger.info(`OTP sent to ${email} for phone ${phone}`);
    return { success: true };
  }
);

// ---------------------------------------------------------------------------
// HTTPS Callable: verifyOtp — UNCHANGED
// ---------------------------------------------------------------------------
export const verifyOtp = onCall(
  { region: "asia-south1" },
  async (request) => {
    const { phone, code } = request.data as {
      phone: string;
      code: string;
    };

    if (!phone || !code) {
      throw new HttpsError("invalid-argument", "phone and code are required.");
    }

    const db = getFirestore();
    const docRef = db.collection("otpVerifications").doc(phone);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new HttpsError(
        "not-found",
        "No OTP found for this phone. Please request a new code."
      );
    }

    const data = doc.data()!;
    const expiresAt = (data.expiresAt as Timestamp).toMillis();

    if (Date.now() > expiresAt) {
      await docRef.delete();
      throw new HttpsError(
        "deadline-exceeded",
        "Code has expired. Please request a new one."
      );
    }

    if (data.code !== code.trim()) {
      throw new HttpsError("unauthenticated", "Incorrect code. Please try again.");
    }

    await docRef.delete();
    logger.info(`OTP verified successfully for phone ${phone}`);
    return { success: true };
  }
);

// ---------------------------------------------------------------------------
// Scheduled: syncEmployeesToFirestore
// REPLACES deactivateResignedStaff — runs same deactivation logic PLUS
// upserts all active employees into the employees/{rowId} collection.
//
// Schedule: "15 3 * * *" UTC = 9:00 PM NPT
// ---------------------------------------------------------------------------
export const syncEmployeesToFirestore = onSchedule(
  {
    schedule: "15 3 * * *",
    timeZone: "UTC",
    region: "asia-south1",
    maxInstances: 1,
  },
  async () => {
    logger.info("syncEmployeesToFirestore: starting...");

    const db = getFirestore();
    const now = Timestamp.now();

    // ── Step 1: Fetch all active staff from API ───────────────────────────
    const allUsers = await fetchAllActiveStaff();

    // ── Step 2: Filter and build employees map ────────────────────────────
    const activePhones = new Set<string>();
    const toUpsert: ApiUser[] = [];

    for (const user of allUsers) {
      if (!passesFilter(user)) continue;
      activePhones.add(user.mobileNo.trim());
      toUpsert.push(user);
    }

    logger.info(
      `syncEmployeesToFirestore: ${toUpsert.length} employees pass filter`
    );

    // ── Step 3: Upsert employees in batches of 400 ────────────────────────
    // Firestore batch limit is 500; stay under with 400.
    const BATCH_SIZE = 400;
    let upsertedCount = 0;

    for (let i = 0; i < toUpsert.length; i += BATCH_SIZE) {
      const chunk = toUpsert.slice(i, i + BATCH_SIZE);
      const batch = db.batch();

      for (const user of chunk) {
        const isHQStaff = HQ_BRANCH_CODES.has(user.branchCode.trim());
        const docRef = db.collection("employees").doc(user.rowId);

        batch.set(
          docRef,
          {
            rowId: user.rowId,
            fullName: user.fullName.trim(),
            branchCode: user.branchCode.trim(),
            branchName: isHQStaff ? "KAMALADI" : user.branchName.trim(),
            mobileNo: user.mobileNo.trim(),
            email: user.email.toLowerCase().trim(),
            departmentName: (user.departmentName ?? "").trim(),
            provinceName: (user.provinceName ?? "").trim(),
            isHQStaff,
            status: "active",
            lastSyncedAt: now,
          },
          { merge: true }
        );

        upsertedCount++;
      }

      await batch.commit();
      logger.info(
        `syncEmployeesToFirestore: upserted chunk ${i / BATCH_SIZE + 1}`
      );
    }

    logger.info(
      `syncEmployeesToFirestore: upserted ${upsertedCount} employees`
    );

    // ── Step 4: Mark resigned employees inactive in employees collection ──
    const employeeSnapshot = await db
      .collection("employees")
      .where("status", "==", "active")
      .get();

    let resignedEmployeeCount = 0;
    const resignedEmployeeBatch = db.batch();

    for (const doc of employeeSnapshot.docs) {
      const phone = (doc.data().mobileNo ?? "").trim();
      if (!activePhones.has(phone)) {
        resignedEmployeeBatch.update(doc.ref, { status: "inactive" });
        resignedEmployeeCount++;
        logger.info(
          `syncEmployeesToFirestore: deactivating employee ${doc.data().fullName} (${phone})`
        );
      }
    }

    if (resignedEmployeeCount > 0) {
      await resignedEmployeeBatch.commit();
    }

    logger.info(
      `syncEmployeesToFirestore: deactivated ${resignedEmployeeCount} resigned employees`
    );

    // ── Step 5: Deactivate resigned staff in users collection ─────────────
    // (Exact logic from original deactivateResignedStaff — preserved)
    const usersSnapshot = await db
      .collection("users")
      .where("role", "==", "staff")
      .where("status", "==", "active")
      .get();

    let deactivatedUsersCount = 0;
    const usersBatch = db.batch();

    for (const doc of usersSnapshot.docs) {
      const data = doc.data();
      const phone = (data.phoneNumber ?? "").trim();
      if (!phone) continue;

      if (!activePhones.has(phone)) {
        usersBatch.update(doc.ref, { status: "inactive" });
        deactivatedUsersCount++;
        logger.info(
          `syncEmployeesToFirestore: deactivating user ${data.name} (${phone})`
        );
      }
    }

    if (deactivatedUsersCount > 0) {
      await usersBatch.commit();
    }

    logger.info(
      `syncEmployeesToFirestore: deactivated ${deactivatedUsersCount} resigned users`
    );
    logger.info("syncEmployeesToFirestore: complete");
  }
);

// ---------------------------------------------------------------------------
// Helper — core QR generation + email logic
// Shared by generateAndEmailQr (single) and sendBulkQrEmails (bulk)
// ---------------------------------------------------------------------------
async function processQrForInvite(inviteId: string, eventId: string): Promise<void> {
  const db = getFirestore();
  const storage = getStorage();

  // ── Fetch invite doc ────────────────────────────────────────────────────
  const inviteRef = db.collection("event_invites").doc(inviteId);
  const inviteDoc = await inviteRef.get();

  if (!inviteDoc.exists) {
    throw new Error(`Invite not found: ${inviteId}`);
  }

  const invite = inviteDoc.data()!;

  // ── Generate QR token ────────────────────────────────────────────────────
  const qrToken = uuidv4();

  // ── Generate QR PNG buffer ───────────────────────────────────────────────
  const qrPngBuffer: Buffer = await QRCode.toBuffer(qrToken, {
    type: "png",
    width: 400,
    margin: 2,
    color: {
      dark: "#1F2937",  // AppTheme.textPrimary equivalent
      light: "#FFFFFF",
    },
  });

  // ── Upload to Firebase Storage ───────────────────────────────────────────
//   const bucket = storage.bucket();
// AFTER
const bucket = storage.bucket('pass-point-9d316.firebasestorage.app');
  const filePath = `events/${eventId}/qr/${inviteId}.png`;
  const file = bucket.file(filePath);

  await file.save(qrPngBuffer, {
    metadata: {
      contentType: "image/png",
      cacheControl: "public, max-age=31536000",
    },
  });

  // Make publicly readable
  await file.makePublic();
  const qrImageUrl = `https://storage.googleapis.com/${bucket.name}/${filePath}`;

  // ── Update invite doc with token + image URL ─────────────────────────────
  await inviteRef.update({
    qrToken,
    qrImageUrl,
  });

  // ── Build warm email ─────────────────────────────────────────────────────
  const firstName = (invite.name as string).trim().split(" ")[0];
  const eventName = invite.eventName as string;
  const eventVenue = invite.eventVenue as string;
  const eventDate = (invite.eventDate as Timestamp).toDate();

  const dateStr = eventDate.toLocaleDateString("en-GB", {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  });

  const htmlBody = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Your Event Invitation — ${eventName}</title>
</head>
<body style="margin:0;padding:0;background:#F8F9FA;font-family:Roboto,Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#F8F9FA;padding:32px 0;">
    <tr>
      <td align="center">
        <table width="560" cellpadding="0" cellspacing="0"
          style="background:#FFFFFF;border-radius:16px;overflow:hidden;
                 box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:linear-gradient(135deg,#6A1B9A,#AB47BC);
                        padding:32px 40px;text-align:center;">
              <p style="margin:0 0 4px 0;color:rgba(255,255,255,0.8);
                         font-size:13px;letter-spacing:1px;text-transform:uppercase;">
                PassPoint · PMLIL
              </p>
              <h1 style="margin:0;color:#FFFFFF;font-size:26px;
                          font-weight:700;letter-spacing:0.3px;">
                You're Invited
              </h1>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px;">
              <p style="margin:0 0 16px 0;font-size:16px;color:#1F2937;">
                Dear <strong>${firstName}</strong>,
              </p>
              <p style="margin:0 0 24px 0;font-size:15px;color:#6B7280;line-height:1.6;">
                You have been invited to attend <strong>${eventName}</strong>.
                Please bring this QR code with you — it will be scanned at entry
                and again when collecting your gift(s).
              </p>

              <!-- Event details box -->
              <table width="100%" cellpadding="0" cellspacing="0"
                style="background:#F3E5F5;border-radius:12px;
                        border:1px solid #E1BEE7;margin-bottom:28px;">
                <tr>
                  <td style="padding:20px 24px;">
                    <p style="margin:0 0 10px 0;font-size:13px;
                               color:#7B1FA2;font-weight:700;
                               text-transform:uppercase;letter-spacing:0.8px;">
                      Event Details
                    </p>
                    <p style="margin:0 0 6px 0;font-size:15px;color:#1F2937;">
                      <strong>${eventName}</strong>
                    </p>
                    <p style="margin:0 0 4px 0;font-size:14px;color:#6B7280;">
                      📅 ${dateStr}
                    </p>
                    <p style="margin:0;font-size:14px;color:#6B7280;">
                      📍 ${eventVenue}
                    </p>
                  </td>
                </tr>
              </table>

              <!-- QR code -->
              <table width="100%" cellpadding="0" cellspacing="0"
                style="margin-bottom:24px;">
                <tr>
                  <td align="center">
                    <p style="margin:0 0 12px 0;font-size:14px;
                               color:#6B7280;text-align:center;">
                      Your personal QR code
                    </p>
                    <img src="${qrImageUrl}" width="200" height="200"
                      alt="Your QR Code"
                      style="border-radius:12px;border:3px solid #E1BEE7;
                             display:block;margin:0 auto;" />
                  </td>
                </tr>
              </table>

              <p style="margin:0 0 8px 0;font-size:13px;color:#9CA3AF;
                          text-align:center;">
                This QR code is unique to you. Please do not share it.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background:#F8F9FA;padding:20px 40px;
                        border-top:1px solid #ECF0F1;text-align:center;">
              <p style="margin:0;font-size:12px;color:#9CA3AF;">
                Sent by PassPoint · Prime Mercantile Limited (PMLIL)
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;

  const textBody = [
    `Dear ${firstName},`,
    ``,
    `You are invited to: ${eventName}`,
    `Date: ${dateStr}`,
    `Venue: ${eventVenue}`,
    ``,
    `Your QR code: ${qrImageUrl}`,
    ``,
    `Please present this QR code at entry. Do not share it.`,
    ``,
    `— PassPoint, PMLIL`,
  ].join("\n");

  // ── Send email ────────────────────────────────────────────────────────────
  await transporter.sendMail({
    from: '"PassPoint Events" <passpoint@pmlil.com>',
    to: (invite.email as string).trim(),
    subject: `Your invitation to ${eventName} — QR Code Inside`,
    text: textBody,
    html: htmlBody,
  });

  // ── Mark email sent on invite doc ─────────────────────────────────────────
  await inviteRef.update({
    qrEmailSent: true,
    qrEmailSentAt: Timestamp.now(),
  });

  logger.info(
    `processQrForInvite: done for ${inviteId} → ${invite.email}`
  );
}

// ---------------------------------------------------------------------------
// HTTPS Callable: generateAndEmailQr
// Input:  { inviteId: string, eventId: string }
// Output: { success: true, qrImageUrl: string }
// ---------------------------------------------------------------------------
export const generateAndEmailQr = onCall(
  { region: "asia-south1" },
  async (request) => {
    const { inviteId, eventId } = request.data as {
      inviteId: string;
      eventId: string;
    };

    if (!inviteId || !eventId) {
      throw new HttpsError(
        "invalid-argument",
        "inviteId and eventId are required."
      );
    }

    try {
      await processQrForInvite(inviteId, eventId);

      // Return the updated image URL
      const db = getFirestore();
      const doc = await db.collection("event_invites").doc(inviteId).get();
      const qrImageUrl = doc.data()?.qrImageUrl as string | undefined;

      logger.info(`generateAndEmailQr: success for invite ${inviteId}`);
      return { success: true, qrImageUrl: qrImageUrl ?? "" };
    } catch (e) {
      logger.error(`generateAndEmailQr: error for invite ${inviteId}`, e);
      throw new HttpsError(
        "internal",
        `QR generation failed: ${(e as Error).message}`
      );
    }
  }
);

// ---------------------------------------------------------------------------
// HTTPS Callable: sendBulkQrEmails
// Input:  { eventId: string }
// Output: { sent: number, failed: number, errors: string[] }
// ---------------------------------------------------------------------------
export const sendBulkQrEmails = onCall(
  { region: "asia-south1",
    timeoutSeconds: 540,   // 9 min — large events may have 400+ invitees
  },
  async (request) => {
    const { eventId } = request.data as { eventId: string };

    if (!eventId) {
      throw new HttpsError("invalid-argument", "eventId is required.");
    }

    const db = getFirestore();

    // Query all invites in this event where QR email not yet sent
    const snapshot = await db
      .collection("event_invites")
      .where("eventId", "==", eventId)
      .where("qrEmailSent", "==", false)
      .get();

    if (snapshot.empty) {
      logger.info(`sendBulkQrEmails: no pending invites for event ${eventId}`);
      return { sent: 0, failed: 0, errors: [] };
    }

    logger.info(
      `sendBulkQrEmails: processing ${snapshot.docs.length} pending invites`
    );

    let sent = 0;
    let failed = 0;
    const errors: string[] = [];

    // Process sequentially to avoid SMTP rate limits
    for (const doc of snapshot.docs) {
      try {
        await processQrForInvite(doc.id, eventId);
        sent++;
      } catch (e) {
        failed++;
        const msg = `${doc.id}: ${(e as Error).message}`;
        errors.push(msg);
        logger.error(`sendBulkQrEmails: failed for invite ${doc.id}`, e);
      }
    }

    logger.info(
      `sendBulkQrEmails: complete — sent: ${sent}, failed: ${failed}`
    );
    return { sent, failed, errors };
  }
);