# GitHub দিয়ে DDialer Android APK বিল্ড করার সম্পূর্ণ নির্দেশিকা
(How to Build DDialer Android APK with GitHub Actions)

আপনি কম্পিউটার বা মোবাইল থেকেই গিটহাব অ্যাকশনস (GitHub Actions) ব্যবহার করে কোনো সফটওয়্যার ইন্সটল না করেই সরাসরি **DDialer Release APK** তৈরি করতে পারবেন।

---

## 🚀 ৪ ধাপে গিটহাব দিয়ে APK তৈরি করুন:

### ধাপ ১: গিটহাবে একটি নতুন রিপোজিটরি তৈরি করুন
1. [GitHub](https://github.com) এ লগইন করুন।
2. উপরে ডানপাশে **`+`** বাটনে ক্লিক করে **`New repository`** সিলেক্ট করুন।
3. Repository name দিন: `ddialer-softphone` (Public বা Private যে কোনোটা বেছে নিতে পারেন)।
4. **`Create repository`** বাটনে ক্লিক করুন।

### ধাপ ২: কোড আপলোড করুন
- **অপশন ক (ব্রাউজার দিয়ে):** এই প্রজেক্টের ZIP ডাউনলোড করে আনজিপ করুন, তারপর গিটহাব রিপোজিটরির **"uploading an existing file"** লিংকে ক্লিক করে সব ফাইল ড্র্যাগ অ্যান্ড ড্রপ করে কমিট করুন।
- **অপশন খ (Git Terminal দিয়ে):**
```bash
git init
git add .
git commit -m "Initial DDialer Android VoIP Softphone"
git branch -M main
git remote add origin https://github.com/<YOUR-USERNAME>/ddialer-softphone.git
git push -u origin main
```

### ধাপ ৩: GitHub Actions চালু করুন
1. আপনার রিপোজিটরির **`Actions`** ট্যাবে যান।
2. বামদিকের মেনু থেকে **`Build DDialer Android APK & AAB`** ওয়ার্কফ্লোটি সিলেক্ট করুন।
3. ডানপাশে **`Run workflow`** ড্রপডাউনে ক্লিক করুন।
4. **`Run workflow`** নীল বাটনে চাপ দিন!

### ধাপ ৪: APK ফাইল ডাউনলোড ও ফোনে ইন্সটল
1. ওয়ার্কফ্লোটি শুরু হবে এবং ৩-৪ মিনিটের মধ্যে ক্লাউড বিল্ড শেষ করে সবুজ টিক (✅) চিহ্ন দেখাবে।
2. বিল্ডের নামের উপর ক্লিক করুন।
3. স্ক্রিনের নিচের দিকে **`Artifacts`** সেকশনে পাবেন:
   - **`ddialer-release-universal-apk`** (সব ধরনের অ্যান্ড্রয়েড ফোনে ইন্সটল করার জন্য সম্পূর্ণ রিলিজ APK)
   - **`ddialer-split-per-abi-apks`** (ছোট সাইজের 64-bit ও 32-bit APK)
   - **`ddialer-playstore-aab`** (গুগল প্লে স্টোরে আপলোড করার জন্য)
4. **`ddialer-release-universal-apk`** ফাইলে ক্লিক করলেই আপনার ফোনে বা পিসিতে সরাসরি ZIP আকারে APK ডাউনলোড হয়ে যাবে!
5. আনজিপ করে আপনার অ্যান্ড্রয়েড ফোনে ইন্সটল করে নিন।
