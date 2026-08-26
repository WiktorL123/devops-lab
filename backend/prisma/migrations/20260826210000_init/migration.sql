-- CreateTable
CREATE TABLE "LabEvent" (
    "id" SERIAL NOT NULL,
    "message" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LabEvent_pkey" PRIMARY KEY ("id")
);

