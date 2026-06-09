-- AlterTable Course
ALTER TABLE "Course" ADD COLUMN IF NOT EXISTS "authorName" TEXT NOT NULL DEFAULT '';
ALTER TABLE "Course" ADD COLUMN IF NOT EXISTS "miniDescription" TEXT NOT NULL DEFAULT '';

-- AlterTable CourseStep
ALTER TABLE "CourseStep" ADD COLUMN IF NOT EXISTS "imageUrl" TEXT;
ALTER TABLE "CourseStep" ADD COLUMN IF NOT EXISTS "isFinalExam" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "CourseStep" ADD COLUMN IF NOT EXISTS "videoDurationSeconds" INTEGER;
ALTER TABLE "CourseStep" ADD COLUMN IF NOT EXISTS "videoUrl" TEXT;

-- AlterTable Product
ALTER TABLE "Product" ADD COLUMN IF NOT EXISTS "images" TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE "Product" ADD COLUMN IF NOT EXISTS "isDeleted" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable User
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "avatar" TEXT;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "blockReason" TEXT;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "blockedAt" TIMESTAMP(3);
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "blockedBy" TEXT;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "courseLives" INTEGER NOT NULL DEFAULT 3;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "exp" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "isBlocked" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "language" TEXT NOT NULL DEFAULT 'ru';
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "level" INTEGER NOT NULL DEFAULT 1;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "livesRestoredAt" TIMESTAMP(3);
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "phone" TEXT;

-- CreateTable Review
CREATE TABLE IF NOT EXISTS "Review" (
    "id" SERIAL NOT NULL,
    "productId" INTEGER NOT NULL,
    "userId" INTEGER NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Review_pkey" PRIMARY KEY ("id")
);

-- CreateTable SupportRequest
CREATE TABLE IF NOT EXISTS "SupportRequest" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER,
    "message" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SupportRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable CourseCompletion
CREATE TABLE IF NOT EXISTS "CourseCompletion" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "courseId" INTEGER NOT NULL,
    "completedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "studentName" TEXT,
    "certificateIssuedAt" TIMESTAMP(3),
    "certificateUuid" TEXT,
    "finalScore" DOUBLE PRECISION,
    "lessonsCompletionPercent" DOUBLE PRECISION,

    CONSTRAINT "CourseCompletion_pkey" PRIMARY KEY ("id")
);

-- CreateTable UserAchievement
CREATE TABLE IF NOT EXISTS "UserAchievement" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "achievementId" TEXT NOT NULL,
    "unlockedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "UserAchievement_pkey" PRIMARY KEY ("id")
);

-- CreateTable AboutSection
CREATE TABLE IF NOT EXISTS "AboutSection" (
    "id" SERIAL NOT NULL,
    "key" TEXT NOT NULL,
    "titleRu" TEXT NOT NULL,
    "titleUz" TEXT NOT NULL,
    "titleEn" TEXT NOT NULL,
    "descRu" TEXT NOT NULL,
    "descUz" TEXT NOT NULL,
    "descEn" TEXT NOT NULL,
    "imageUrl" TEXT,
    "mapIframe" TEXT,
    "order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "AboutSection_pkey" PRIMARY KEY ("id")
);

-- CreateTable UserBlock
CREATE TABLE IF NOT EXISTS "UserBlock" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "blockedBy" TEXT NOT NULL,
    "blockedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "unblockedAt" TIMESTAMP(3),
    "reason" TEXT,

    CONSTRAINT "UserBlock_pkey" PRIMARY KEY ("id")
);

-- CreateTable AdminAction
CREATE TABLE IF NOT EXISTS "AdminAction" (
    "id" SERIAL NOT NULL,
    "adminId" INTEGER NOT NULL,
    "actionType" TEXT NOT NULL,
    "targetUserId" INTEGER NOT NULL,
    "details" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AdminAction_pkey" PRIMARY KEY ("id")
);

-- CreateTable UserLessonProgress
CREATE TABLE IF NOT EXISTS "UserLessonProgress" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "stepId" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'not_started',
    "scrollCompleted" BOOLEAN NOT NULL DEFAULT false,
    "timeSpentSeconds" INTEGER NOT NULL DEFAULT 0,
    "lessonStartedAt" TIMESTAMP(3),
    "isTimerCompleted" BOOLEAN NOT NULL DEFAULT false,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "quizAttempts" INTEGER NOT NULL DEFAULT 0,
    "cooldownUntil" TIMESTAMP(3),

    CONSTRAINT "UserLessonProgress_pkey" PRIMARY KEY ("id")
);

-- CreateTable UserCourseBlock
CREATE TABLE IF NOT EXISTS "UserCourseBlock" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "courseId" INTEGER NOT NULL,
    "blockedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "blockedUntil" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserCourseBlock_pkey" PRIMARY KEY ("id")
);

-- CreateTable ScreenshotViolation
CREATE TABLE IF NOT EXISTS "ScreenshotViolation" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "stepId" INTEGER NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ScreenshotViolation_pkey" PRIMARY KEY ("id")
);

-- CreateTable TelegramUser
CREATE TABLE IF NOT EXISTS "TelegramUser" (
    "id" BIGINT NOT NULL,
    "username" TEXT,
    "firstName" TEXT,
    "lastName" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TelegramUser_pkey" PRIMARY KEY ("id")
);

-- CreateTable TelegramMessage
CREATE TABLE IF NOT EXISTS "TelegramMessage" (
    "id" SERIAL NOT NULL,
    "telegramUserId" BIGINT NOT NULL,
    "text" TEXT NOT NULL,
    "isFromUser" BOOLEAN NOT NULL,
    "adminId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TelegramMessage_pkey" PRIMARY KEY ("id")
);

-- CreateTable TelegramBotLog
CREATE TABLE IF NOT EXISTS "TelegramBotLog" (
    "id" SERIAL NOT NULL,
    "level" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TelegramBotLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "CourseCompletion_certificateUuid_key" ON "CourseCompletion"("certificateUuid");
CREATE UNIQUE INDEX IF NOT EXISTS "CourseCompletion_userId_courseId_key" ON "CourseCompletion"("userId", "courseId");
CREATE UNIQUE INDEX IF NOT EXISTS "UserAchievement_userId_achievementId_key" ON "UserAchievement"("userId", "achievementId");
CREATE UNIQUE INDEX IF NOT EXISTS "AboutSection_key_key" ON "AboutSection"("key");
CREATE UNIQUE INDEX IF NOT EXISTS "UserLessonProgress_userId_stepId_key" ON "UserLessonProgress"("userId", "stepId");
CREATE UNIQUE INDEX IF NOT EXISTS "UserCourseBlock_userId_courseId_key" ON "UserCourseBlock"("userId", "courseId");

-- AddForeignKey
ALTER TABLE "Review" DROP CONSTRAINT IF EXISTS "Review_productId_fkey";
ALTER TABLE "Review" ADD CONSTRAINT "Review_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Review" DROP CONSTRAINT IF EXISTS "Review_userId_fkey";
ALTER TABLE "Review" ADD CONSTRAINT "Review_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "SupportRequest" DROP CONSTRAINT IF EXISTS "SupportRequest_userId_fkey";
ALTER TABLE "SupportRequest" ADD CONSTRAINT "SupportRequest_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "UserAchievement" DROP CONSTRAINT IF EXISTS "UserAchievement_userId_fkey";
ALTER TABLE "UserAchievement" ADD CONSTRAINT "UserAchievement_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "UserBlock" DROP CONSTRAINT IF EXISTS "UserBlock_userId_fkey";
ALTER TABLE "UserBlock" ADD CONSTRAINT "UserBlock_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "AdminAction" DROP CONSTRAINT IF EXISTS "AdminAction_adminId_fkey";
ALTER TABLE "AdminAction" ADD CONSTRAINT "AdminAction_adminId_fkey" FOREIGN KEY ("adminId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "AdminAction" DROP CONSTRAINT IF EXISTS "AdminAction_targetUserId_fkey";
ALTER TABLE "AdminAction" ADD CONSTRAINT "AdminAction_targetUserId_fkey" FOREIGN KEY ("targetUserId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "UserLessonProgress" DROP CONSTRAINT IF EXISTS "UserLessonProgress_userId_fkey";
ALTER TABLE "UserLessonProgress" ADD CONSTRAINT "UserLessonProgress_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "UserLessonProgress" DROP CONSTRAINT IF EXISTS "UserLessonProgress_stepId_fkey";
ALTER TABLE "UserLessonProgress" ADD CONSTRAINT "UserLessonProgress_stepId_fkey" FOREIGN KEY ("stepId") REFERENCES "CourseStep"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "UserCourseBlock" DROP CONSTRAINT IF EXISTS "UserCourseBlock_userId_fkey";
ALTER TABLE "UserCourseBlock" ADD CONSTRAINT "UserCourseBlock_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "UserCourseBlock" DROP CONSTRAINT IF EXISTS "UserCourseBlock_courseId_fkey";
ALTER TABLE "UserCourseBlock" ADD CONSTRAINT "UserCourseBlock_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "ScreenshotViolation" DROP CONSTRAINT IF EXISTS "ScreenshotViolation_userId_fkey";
ALTER TABLE "ScreenshotViolation" ADD CONSTRAINT "ScreenshotViolation_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "ScreenshotViolation" DROP CONSTRAINT IF EXISTS "ScreenshotViolation_stepId_fkey";
ALTER TABLE "ScreenshotViolation" ADD CONSTRAINT "ScreenshotViolation_stepId_fkey" FOREIGN KEY ("stepId") REFERENCES "CourseStep"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "TelegramMessage" DROP CONSTRAINT IF EXISTS "TelegramMessage_telegramUserId_fkey";
ALTER TABLE "TelegramMessage" ADD CONSTRAINT "TelegramMessage_telegramUserId_fkey" FOREIGN KEY ("telegramUserId") REFERENCES "TelegramUser"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "TelegramMessage" DROP CONSTRAINT IF EXISTS "TelegramMessage_adminId_fkey";
ALTER TABLE "TelegramMessage" ADD CONSTRAINT "TelegramMessage_adminId_fkey" FOREIGN KEY ("adminId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
