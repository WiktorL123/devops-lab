-- CreateTable
CREATE TABLE "CounterfactualIncident" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "prevention" TEXT NOT NULL,
    "severity" TEXT NOT NULL,
    "confidence" INTEGER NOT NULL,
    "occurredOn" DATE NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CounterfactualIncident_pkey" PRIMARY KEY ("id")
);
