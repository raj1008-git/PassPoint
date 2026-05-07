
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import * as nodemailer from "nodemailer";

// Initialize Firebase Admin
initializeApp();

// ---------------------------------------------------------------------------
// SMTP Transporter — Office365
// ---------------------------------------------------------------------------
const transporter = nodemailer.createTransport({
  host: "mail.pmlil.com",
  port: 587,
  secure: false, // STARTTLS
  auth: {
    user: "passpoint@pmlil.com",
    pass: "fm?$K6pK[2Co7^lD",
  },
  tls: {
    rejectUnauthorized: false,
  },
});

// ---------------------------------------------------------------------------
// API Config
// ---------------------------------------------------------------------------
const API_BASE_URL = "https://api.pmlil.com";
const API_USERNAME = "PMLI_INTERNAL";
const API_PASSWORD = "a8pP9{(992c";
const INVALID_PHONES = new Set(["9800000000", "9700000000"]);

// ---------------------------------------------------------------------------
// Helper — generate 6-digit OTP
// ---------------------------------------------------------------------------
function generateOtp(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// ---------------------------------------------------------------------------
// HTTPS Callable: sendOtp
// Called by Flutter when user confirms identity (Step 2 → Step 2.5)
//
// Request:  { phone: string, email: string, name: string }
// Response: { success: true }
// ---------------------------------------------------------------------------
export const sendOtp = onCall(
  { region: "asia-south1" },
  async (request) => {
    const { phone, email, name } = request.data as {
      phone: string;
      email: string;
      name: string;
    };

    // Basic validation
    if (!phone || !email || !name) {
      throw new HttpsError("invalid-argument", "phone, email, and name are required.");
    }
    if (!email.endsWith("@pmlil.com")) {
      throw new HttpsError("invalid-argument", "Email must be a pmlil.com address.");
    }

    const db = getFirestore();
    const otp = generateOtp();
    const expiresAt = Timestamp.fromMillis(Date.now() + 5 * 60 * 1000); // 5 minutes

    // Store OTP in Firestore (overwrites any previous pending OTP for this phone)
    await db.collection("otpVerifications").doc(phone).set({
      code: otp,
      email: email.toLowerCase().trim(),
      name: name.trim(),
      expiresAt,
      createdAt: Timestamp.now(),
    });

    // Send email via Office365 SMTP
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
// HTTPS Callable: verifyOtp
// Called by Flutter when user submits the 6-digit code
//
// Request:  { phone: string, code: string }
// Response: { success: true }
// Throws HttpsError on wrong code, expired, or not found
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
      throw new HttpsError("not-found", "No OTP found for this phone. Please request a new code.");
    }

    const data = doc.data()!;
    const expiresAt = (data.expiresAt as Timestamp).toMillis();

    if (Date.now() > expiresAt) {
      // Clean up expired OTP
      await docRef.delete();
      throw new HttpsError("deadline-exceeded", "Code has expired. Please request a new one.");
    }

    if (data.code !== code.trim()) {
      throw new HttpsError("unauthenticated", "Incorrect code. Please try again.");
    }

    // ✅ Correct — delete OTP so it can't be reused
    await docRef.delete();

    logger.info(`OTP verified successfully for phone ${phone}`);
    return { success: true };
  }
);

// ---------------------------------------------------------------------------
// Fetch JWT token from PMLIL API
// ---------------------------------------------------------------------------
async function getApiToken(): Promise<string> {
  const response = await fetch(`${API_BASE_URL}/api/Auth/token`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      userName: API_USERNAME,
      password: API_PASSWORD,
    }),
  });

  if (!response.ok) {
    throw new Error(`Token fetch failed: ${response.status}`);
  }

  const data = await response.json() as { tokenString: string };
  return data.tokenString;
}

// ---------------------------------------------------------------------------
// Fetch all active staff from API (paginated)
// ---------------------------------------------------------------------------
async function fetchAllActivePhones(): Promise<Set<string>> {
  const token = await getApiToken();
  const activePhones = new Set<string>();
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
      userList: Array<{
        mobileNo: string;
        email: string;
        fullName: string;
        branchCode: string;
      }>;
      totalRecords: number;
    };

    const userList = data.userList ?? [];

    for (const user of userList) {
      const phone = (user.mobileNo ?? "").trim();
      const email = (user.email ?? "").toLowerCase().trim();
      const name = (user.fullName ?? "").trim();

      if (!email.endsWith("@pmlil.com")) continue;
      if (!phone || phone.length < 7) continue;
      if (INVALID_PHONES.has(phone)) continue;
      if (name === name.toUpperCase() && name.length <= 20) continue;

      activePhones.add(phone);
    }

    start += pageSize;
    if (start >= data.totalRecords || userList.length < pageSize) break;
  }

  logger.info(`Fetched ${activePhones.size} active phones from API`);
  return activePhones;
}

// ---------------------------------------------------------------------------
// Scheduled Function — deactivate resigned staff
// Every day at 13:30 UTC = 7:15 PM NPT
// ---------------------------------------------------------------------------
export const deactivateResignedStaff = onSchedule(
  {
    schedule: "30 13 * * *",
    timeZone: "UTC",
    maxInstances: 1,
  },
  async () => {
    logger.info("Starting resigned staff deactivation...");

    const db = getFirestore();
    const activePhones = await fetchAllActivePhones();

    const snapshot = await db
      .collection("users")
      .where("role", "==", "staff")
      .where("status", "==", "active")
      .get();

    if (snapshot.empty) {
      logger.info("No active staff found in Firestore.");
      return;
    }

    const batch = db.batch();
    let deactivatedCount = 0;

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const phone = (data.phoneNumber ?? "").trim();

      if (!phone) continue;

      if (!activePhones.has(phone)) {
        batch.update(doc.ref, { status: "inactive" });
        deactivatedCount++;
        logger.info(`Deactivating: ${data.name} (${phone})`);
      }
    }

    if (deactivatedCount > 0) {
      await batch.commit();
      logger.info(`Deactivated ${deactivatedCount} resigned staff.`);
    } else {
      logger.info("No resigned staff found. All active.");
    }
  }
);