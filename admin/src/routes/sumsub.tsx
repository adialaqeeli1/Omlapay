import { createFileRoute } from '@tanstack/react-router'
import SumsubKyc from '@/components/sumsub-kyc'

export const Route = createFileRoute('/sumsub')({
  component: SumsubPage,
})

function SumsubPage() {
  return (
    <div className="min-h-screen bg-[#111111] py-10 px-5">
      <div className="max-w-4xl mx-auto flex flex-col gap-10">
        <h2 className="text-2xl font-semibold text-light-main">Sumsub KYC Testing</h2>
        <SumsubKyc />
      </div>
    </div>
  )
}
