const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const branches = [
  { name: 'KAMALADI', code: 'HQ', isHeadquarter: true, hasDepartments: true, hasReceptionist: true },
  { name: 'ITAHARI', code: 'ITH' },
  { name: 'DAMAK', code: 'DMK' },
  { name: 'BIRATNAGAR', code: 'BRT' },
  { name: 'DHARAN', code: 'DHR' },
  { name: 'ILAM', code: 'ILM' },
  { name: 'DHANKUTA', code: 'DHK' },
  { name: 'PHIDIM', code: 'PHD' },
  { name: 'BIRTAMODE', code: 'BTM' },
  { name: 'GAIGHAT', code: 'GGH' },
  { name: 'OKHALDHUNGA', code: 'OKH' },
  { name: 'KATARI', code: 'KTR' },
  { name: 'BHOJPUR', code: 'BHJ' },
  { name: 'KHOTANG', code: 'KHT' },
  { name: 'INARUWA', code: 'INR' },
  { name: 'CHANDRAGADHI', code: 'CHN' },
  { name: 'BIRGUNJ ADARSHANAGAR', code: 'BRA' },
  { name: 'KALAIYA', code: 'KLY' },
  { name: 'POKHARIYA', code: 'PKY' },
  { name: 'GARUDA', code: 'GRD' },
  { name: 'LAHAN', code: 'LHN' },
  { name: 'JANAKPUR', code: 'JNK' },
  { name: 'HARIWON', code: 'HRW' },
  { name: 'MIRCHAIYA', code: 'MRC' },
  { name: 'SIMARA', code: 'SMR' },
  { name: 'RAJBIRAJ', code: 'RJB' },
  { name: 'BARDIBASH', code: 'BRD' },
  { name: 'GAUR', code: 'GUR' },
  { name: 'MALANGWA', code: 'MLG' },
  { name: 'KANCHANPUR', code: 'KCP' },
  { name: 'NIJGADH', code: 'NJG' },
  { name: 'CORPORATE OFFICE', code: 'COR' },
  { name: 'KATHMANDU BRANCH', code: 'KTM' },
  { name: 'BHAKTAPUR', code: 'BKT' },
  { name: 'SINDHULI', code: 'SND' },
  { name: 'OLD BANESHWOR', code: 'OBN' },
  { name: 'NARAYANGHAT', code: 'NRY' },
  { name: 'NUWAKOT', code: 'NWK' },
  { name: 'BANEPA', code: 'BNP' },
  { name: 'PATAN', code: 'PTN' },
  { name: 'KALANKI', code: 'KLK' },
  { name: 'DHADING', code: 'DHD' },
  { name: 'GONGABU', code: 'GNG' },
  { name: 'HATTIGAUDA', code: 'HTG' },
  { name: 'HETAUDA', code: 'HET' },
  { name: 'BHAISEPATI', code: 'BHS' },
  { name: 'KOTESHWOR', code: 'KTS' },
  { name: 'JORPATI', code: 'JRP' },
  { name: 'KIRTIPUR', code: 'KRT' },
  { name: 'TANDI', code: 'TND' },
  { name: 'KAWASOTI', code: 'KWS' },
  { name: 'BARHABISE', code: 'BRH' },
  { name: 'THANKOT', code: 'THK' },
  { name: 'CHABAHIL', code: 'CHB' },
  { name: 'PEPSICOLA', code: 'PEP' },
  { name: 'NAXAL', code: 'NXL' },
  { name: 'KALANKI-A', code: 'KLA' },
  { name: 'GONGABU-A', code: 'GNA' },
  { name: 'LALITPUR', code: 'LLP' },
  { name: 'BHAKTAPUR-A', code: 'BKA' },
  { name: 'BANESHWOR', code: 'BNS' },
  { name: 'GOLFUTAR', code: 'GLF' },
  { name: 'MANTHALI', code: 'MTH' },
  { name: 'SWOYAMBHU', code: 'SWY' },
  { name: 'POKHARA', code: 'POK' },
  { name: 'LEKHNATH', code: 'LKH' },
  { name: 'BAGLUNG', code: 'BGL' },
  { name: 'BESISAHAR', code: 'BES' },
  { name: 'BURTIBANG', code: 'BUR' },
  { name: 'DAMAULI', code: 'DAM' },
  { name: 'GORKHA', code: 'GOR' },
  { name: 'BENI', code: 'BEN' },
  { name: 'GALKOT', code: 'GLK' },
  { name: 'WALLING', code: 'WAL' },
  { name: 'BAGAR', code: 'BAG' },
  { name: 'KUSHMA', code: 'KSH' },
  { name: 'BUTWAL', code: 'BTW' },
  { name: 'NEPALGUNJ', code: 'NPG' },
  { name: 'GHORAHI', code: 'GHR' },
  { name: 'PALPA', code: 'PLP' },
  { name: 'KAPILVASTU', code: 'KPL' },
  { name: 'BHAIRAHAWA', code: 'BHR' },
  { name: 'BARDAGHAT', code: 'BDG' },
  { name: 'PYUTHAN', code: 'PYT' },
  { name: 'GULARIYA', code: 'GLR' },
  { name: 'KOHALPUR', code: 'KHL' },
  { name: 'MURGIYA', code: 'MRG' },
  { name: 'GULMI', code: 'GLM' },
  { name: 'JEETPUR-KAPILBASTU', code: 'JKP' },
  { name: 'SANDHIKHARKA', code: 'SDK' },
  { name: 'ARGHAKHACHI', code: 'ARG' },
  { name: 'DANG', code: 'DNG' },
  { name: 'TULSIPUR', code: 'TLS' },
  { name: 'RAJAPUR', code: 'RJP' },
  { name: 'BASGADHI', code: 'BSG' },
  { name: 'LAMAHI', code: 'LMH' },
  { name: 'PARASI', code: 'PRS' },
  { name: 'MUSIKOT', code: 'MSK' },
  { name: 'SURKHET', code: 'SRK' },
  { name: 'JUMLA', code: 'JML' },
  { name: 'BABIYACHAUR', code: 'BBC' },
  { name: 'SALYAN', code: 'SLY' },
  { name: 'DAILEKH', code: 'DLK' },
  { name: 'CHAURJAHARI', code: 'CJH' },
  { name: 'DHANGADHI', code: 'DNG' },
  { name: 'MAHENDRANAGAR', code: 'MHN' },
  { name: 'LAMKI', code: 'LMK' },
  { name: 'ACHAM', code: 'ACH' },
  { name: 'BELAURI', code: 'BLR' },
  { name: 'TIKAPUR', code: 'TKP' },
  { name: 'DADELDHURA', code: 'DDL' },
  { name: 'DARCHULA', code: 'DCL' },
  { name: 'BAJURA', code: 'BJR' },
  { name: 'BAJHANG', code: 'BJH' },
  { name: 'ATTARIYA', code: 'ATR' },
  { name: 'PATAN(BAITADI)', code: 'PTB' },
  { name: 'JHALARI', code: 'JHL' },
  { name: 'SUKHAD', code: 'SKD' },
  { name: 'SANFEBAGAR', code: 'SFB' },
];

async function seedBranches() {
  console.log('Starting branch seeding...');

  const batch = db.batch();
  const now = admin.firestore.Timestamp.now();

  branches.forEach((branch) => {
    const branchId = branch.name.toLowerCase().replace(/[\s()/-]/g, '_');
    const branchRef = db.collection('branches').doc(branchId);

    batch.set(branchRef, {
      name: branch.name,
      code: branch.code,
      isHeadquarter: branch.isHeadquarter || false,
      hasDepartments: branch.hasDepartments || false,
      hasReceptionist: branch.hasReceptionist || false,
      createdAt: now,
    });
  });

  await batch.commit();
  console.log(`✅ Successfully seeded ${branches.length} branches!`);
  process.exit(0);
}

seedBranches().catch((error) => {
  console.error('❌ Error seeding branches:', error);
  process.exit(1);
});
