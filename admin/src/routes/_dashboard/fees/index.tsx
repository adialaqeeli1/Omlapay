import { createFileRoute } from '@tanstack/react-router'
import { PencilIcon, DollarIcon, AvatarIcon, LockIcon } from '@/components/icon'
import DateRangeFilter from '@/components/common/date-range-filter'
import { Popover, PopoverButton, PopoverPanel } from '@headlessui/react'
import clsx from 'clsx'
import { type ColumnDef } from '@tanstack/react-table'
import { useMemo, useState } from 'react'
import { dummyFees } from '../../../data'
import { DataTable } from '@/components/common/data-table'
import Modal from '@/components/common/modal'
import OTPInput from 'react-otp-input'

export const Route = createFileRoute('/_dashboard/fees/')({
  component: FeesPage,
})

type User = (typeof dummyFees)[0]

function FeesPage() {
  const stats = [
    {
      title: 'External Transfer Profit (in USD)',
      value: '$509',
      description: 'Total profit earned from external transfer',
    },
    {
      title: 'Swap Profit (in USD)',
      value: '$725',
      description: 'Total profit earned from swap',
    },
    {
      title: 'Total Profit Earned (in USD)',
      value: '$999',
      description: 'Total profit earned from all fees',
    },
  ]

  const columns = useMemo<ColumnDef<User>[]>(
    () => [
      {
        accessorKey: 'transactionID',
        header: 'Transaction ID',
      },
      {
        accessorKey: 'from_name',
        header: 'From',
        cell: ({ row }) => {
          const name = row.getValue('from_name') as string
          const email = row.original.from_email
          return (
            <div className="flex items-center gap-1">
              <AvatarIcon />
              <div className="flex flex-col">
                <span className="text-xs font-inter text-primary font-semibold">
                  {name}
                </span>
                <span className="text-[#9C9C9C] text-xs font-medium font-inter">
                  {email}
                </span>
              </div>
            </div>
          )
        },
      },
      {
        accessorKey: 'to_name',
        header: 'To',
        cell: ({ row }) => {
          const name = row.getValue('to_name') as string
          const email = row.original.to_email
          return (
            <div className="flex items-center gap-1">
              <AvatarIcon />
              <div className="flex flex-col">
                <span className="text-xs font-inter text-primary font-semibold">
                  {name}
                </span>
                <span className="text-[#9C9C9C] text-xs font-medium font-inter">
                  {email}
                </span>
              </div>
            </div>
          )
        },
      },

      {
        accessorKey: 'amount',
        header: 'Amount',
      },
      {
        accessorKey: 'type',
        header: 'Type',
        cell: ({ row }) => {
          const type = row.getValue('type') as string
          return (
            <span
              className={`inline-flex px-2 py-0.5 text-xs font-medium rounded-[8px] ${
                type === 'External Transfer'
                  ? 'bg-[#2B7FFF33] border border-[#2B7FFF4D] text-[#51A2FF]'
                  : 'bg-[#AD46FF33] border border-[#AD46FF4D] text-[#C27AFF]'
              }`}
            >
              {type}
            </span>
          )
        },
      },
      {
        accessorKey: 'profit',
        header: 'Profit',
        cell: ({ row }) => {
          const profit = row.getValue('profit') as string
          return (
            <span className="text-xs font-inter text-primary font-semibold">
              {profit}
            </span>
          )
        },
      },
    ],
    []
  )

  return (
    <div className="max-w-7xl mx-auto px-5 py-10 flex flex-col gap-10 w-full">
      <h3 className="text-2xl font-semibold font-poppins text-[#E5FFFD]">
        Fees Management
      </h3>
      <div className="grid grid-cols-3 gap-6">
        {stats.map(stat => (
          <div className="col-span-1 bg-primary rounded-[14px] p-6 flex flex-col gap-4">
            <span className="text-base font-normal font-poppins text-[#FEFEFE]">
              {stat.title}
            </span>
            <h2 className="text-4xl font-bold font-poppins text-white">
              {stat.value}
            </h2>
            <span className="text-sm font-normal font-poppins text-white">
              {stat.description}
            </span>
          </div>
        ))}
      </div>
      <div className="flex w-full gap-4">
        <FeeUpdateCard
          title="External Transfer Fee (%)"
          value="2.5%"
          description="Funds sent outside the platform"
        />
        <FeeUpdateCard
          title="Swap Fee (%)"
          value="2.5%"
          description="Applied to all internal asset swaps"
        />
      </div>
      <div className="flex flex-col gap-3 p-6 rounded-[10px] bg-[#1E29394D] border border-[#364153]">
        <span className="text-lg font-normal font-poppins text-white">
          Important Information
        </span>
        <ul className="list-disc list-inside marker:text-primary font-poppins text-[#D1D5DC] text-sm font-poppins font-normal">
          <li>Fee changes require 2-factor authentication for security</li>
          <li>Updated fees apply only to new transactions</li>
          <li>Existing and completed transactions remain unaffected</li>
          <li>Fee values must be within allowed business limits (0% - 10%)</li>
        </ul>
      </div>
      <div className="flex flex-col gap-[14px] w-full">
        <div className="flex justify-between items-center border-b border-[#364153] px-6 py-4">
          <div className="flex flex-col gap-1">
            <h5 className="text-lg font-normal font-poppins text-white">
              Recent Transactions
            </h5>
            <span className="text-sm font-normal font-poppins text-[#99A1AF]">
              View profit earned from transaction fees
            </span>
          </div>
          <div className="flex gap-6 items-center">
            <DateRangeFilter />
            <TypeFilter />
          </div>
        </div>
        <DataTable
          columns={columns}
          data={dummyFees}
          enableSorting
          className="w-full"
          enablePagination
        />
      </div>
    </div>
  )
}

const TypeFilter = () => {
  const statuses = [
    {
      label: 'External Transfer',
      value: 'external-transfer',
    },
    {
      label: 'Swap',
      value: 'swap',
    },
  ]
  return (
    <Popover>
      <PopoverButton className="whitespace-nowrap outline-none border border-primary-dark text-primary h-12 px-4 py-2 text-base font-medium font-roboto inline-flex items-center gap-2 rounded-[6px] cursor-pointer">
        <DollarIcon /> Filter by type
      </PopoverButton>
      <PopoverPanel
        transition
        anchor="bottom end"
        className="rounded-[24px] bg-[#282828] w-[170px] overflow-hidden transition duration-200 ease-in-out [--anchor-gap:--spacing(5)] data-closed:-translate-y-1 data-closed:opacity-0"
      >
        <div className="w-auto p-4 flex flex-col gap-6 items-start">
          {statuses.map(status => (
            <button
              key={status.value}
              className={clsx(
                'text-sm font-medium font-roboto cursor-pointer outline-none p-2 w-full text-start rounded-md',
                (status.value === 'external-transfer' && 'text-[#51A2FF]') ||
                  (status.value === 'swap' && 'text-[#C27AFF]')
              )}
            >
              {status.label}
            </button>
          ))}
        </div>
      </PopoverPanel>
    </Popover>
  )
}

const FeeUpdateCard = ({
  title,
  value,
  description,
}: {
  title: string
  value: string
  description: string
}) => {
  const [isOnEditMode, setIsOnEditMode] = useState(false)
  const [isOpen, setIsOpen] = useState(false)
  const [verifyType, setVerifyType] = useState<'mobile' | 'email'>('mobile')
  const [otp, setOtp] = useState('')
  const [otpError, setOtpError] = useState(false)
  const [verificationError, setVerificationError] = useState('')
  const [otpSendSuccess, setOtpSendSuccess] = useState(false)

  const handleOtpChange = (value: string) => {
    setOtp(value)
    if (value.length !== 6) {
      setOtpError(true)
    } else {
      setOtpError(false)
    }
  }
  const handleOpen = () => {
    setIsOpen(true)
  }
  const handleClose = () => {
    setIsOpen(false)
  }
  return (
    <>
      <div className="w-1/2 bg-[#0F1511] rounded-[14px] p-6 flex flex-col gap-4 border border-[#364153]">
        <div className="flex items-center justify-between">
          <span className="text-base font-normal font-poppins text-[#D1D5DC]">
            {title}
          </span>
          {!isOnEditMode && (
            <button
              onClick={() => setIsOnEditMode(true)}
              className="text-sm font-normal font-poppins text-[#99A1AF] inline-flex items-center gap-2.5"
            >
              Edit
              <PencilIcon />
            </button>
          )}
        </div>
        <div className="flex flex-col gap-1">
          {isOnEditMode ? (
            <div className="flex flex-col gap-4">
              <div className="flex flex-col gap-1">
                <input
                  type="text"
                  placeholder="Enter a value between 0% and 10%"
                  className="h-12 bg-[#2626264D] border border-[#364153] rounded-[8px] py-1 px-3 text-sm font-normal outline-none text-white"
                />
                <span className="text-sm font-normal font-poppins text-[#6A7282]">
                  Funds sent outside the platform
                </span>
              </div>
              <span className="text-sm font-normal font-poppins text-[#F92A2A]">
                Must be between 0% and 10%
              </span>
              <div className="flex gap-2">
                <button
                  onClick={handleOpen}
                  className="w-[102px] py-2.5 px-4 rounded-[8px] border border-[#2BA39B] bg-[#2BA39B80] text-sm font-semibold font-inter text-white"
                >
                  Update
                </button>
                <button
                  onClick={() => setIsOnEditMode(false)}
                  className="w-[102px] py-2.5 px-4 rounded-[8px] border border-[#D5D7DA] bg-[#FFFFFF1F] text-sm font-semibold font-inter text-[#C1C1C1]"
                >
                  Cancel
                </button>
              </div>
            </div>
          ) : (
            <>
              <h2 className="text-4xl font-bold font-poppins text-primary">
                {value}
              </h2>
              <p className="text-sm font-normal font-poppins text-[#6A7282]">
                {description}
              </p>
            </>
          )}
        </div>
      </div>
      <Modal isOpen={isOpen} onClose={handleClose} maxWidth="max-w-[512px]">
        <div className="flex flex-col gap-6">
          <div className="flex flex-col gap-4">
            <div className="h-12 w-12 rounded-[10px] flex items-center justify-center bg-[#2BA39B1F] text-primary">
              <LockIcon />
            </div>

            <div className="flex flex-col gap-1">
              <h3 className="text-lg font-inter font-semibold text-light">
                Verify Your Account
              </h3>
              <p className="text-sm font-inter font-normal text-[#697077]">
                To verify yourself, please enter your registered mobile number
                or email address to receive verification code.
              </p>
            </div>
          </div>
          <div className="flex flex-col gap-5 w-full">
            <div className="flex flex-col gap-5">
              <div className="w-[345px] p-1 rounded-[12px] bg-[#E5E5E5] mx-auto">
                <button
                  type="button"
                  className={clsx(
                    'w-1/2 text-base font-semibold font-inter rounded-[8px] h-9',
                    verifyType === 'mobile' && 'bg-[#2AA29A] text-white'
                  )}
                  onClick={() => setVerifyType('mobile')}
                >
                  Mobile
                </button>
                <button
                  type="button"
                  className={clsx(
                    'w-1/2 text-base font-semibold font-inter rounded-[8px] h-9',
                    verifyType === 'email' && 'bg-[#2AA29A] text-white'
                  )}
                  onClick={() => setVerifyType('email')}
                >
                  Email
                </button>
              </div>
            </div>
            {verifyType === 'mobile' && (
              <div className="flex flex-col gap-1.5 sm:gap-2">
                <div className="w-full h-14 px-4 py-2 flex items-center gap-2 justify-between bg-transparent border border-[#282828] rounded-[8px]">
                  <input
                    type="tel"
                    placeholder="Enter mobile number"
                    className="w-full outline-none text-sm font-normal font-roboto bg-transparent outline-none"
                  />
                  <button
                    onClick={() => setOtpSendSuccess(true)}
                    disabled={otpSendSuccess}
                    className={clsx(
                      'text-[#6D6D6D] text-xs font-semibold font-roboto whitespace-nowrap',
                      otpSendSuccess && 'opacity-50 cursor-not-allowed'
                    )}
                  >
                    Send OTP
                  </button>
                </div>
              </div>
            )}
            {verifyType === 'email' && (
              <div className="flex flex-col gap-1.5 sm:gap-2">
                <div className="w-full h-14 px-4 py-2 flex items-center gap-2 justify-between bg-transparent border border-[#282828] rounded-[8px]">
                  <input
                    type="text"
                    placeholder="Enter email address"
                    className="w-full outline-none text-sm font-normal font-roboto bg-transparent outline-none"
                  />
                  <button
                    onClick={() => setOtpSendSuccess(true)}
                    disabled={otpSendSuccess}
                    className={clsx(
                      'text-[#6D6D6D] text-xs font-semibold font-roboto whitespace-nowrap',
                      otpSendSuccess && 'opacity-50 cursor-not-allowed'
                    )}
                  >
                    Send OTP
                  </button>
                </div>
              </div>
            )}
            {otpSendSuccess && (
              <div className="max-w-full sm:max-w-[410px] flex flex-col gap-2">
                <span className="text-sm font-roboto text-light font-medium">
                  Verification code
                </span>
                <OTPInput
                  value={otp}
                  onChange={handleOtpChange}
                  numInputs={6}
                  inputType="number"
                  renderSeparator={<span />}
                  renderInput={props => (
                    <input
                      {...props}
                      className={clsx(
                        'min-w-12 min-h-12 sm:min-w-[54px] sm:min-h-[54px] w-full h-full bg-transparent text-black text-lg sm:text-2xl rounded-xl outline-none border focus:border-[#4020FF]',
                        otpError || verificationError
                          ? 'border-red-500'
                          : 'border-secondary-lighter'
                      )}
                    />
                  )}
                  containerStyle={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    gap: 1,
                  }}
                />

                {otpError || verificationError ? (
                  <span className="text-xs text-red-500">
                    {otpError ? 'Please enter a valid OTP' : verificationError}
                  </span>
                ) : (
                  <span className="text-sm font-inter text-light font-normal">
                    You should receive the verification codes in{' '}
                    <span className="text-primary">5 Seconds</span>
                  </span>
                )}
              </div>
            )}
          </div>
          <div className="flex gap-3 w-full">
            <button
              onClick={handleClose}
              className="flex-1 bg-[#FFFFFF1F] rounded-[8px] py-2.5 px-4 border border-[#D5D7DA] text-base font-semibold font-inter text-light"
            >
              Cancel
            </button>
            <button
              onClick={() => handleClose()}
              className="flex-1 bg-primary rounded-[8px] py-2.5 px-4 border border-primary-dark text-base font-semibold font-inter text-white"
            >
              Confirm
            </button>
          </div>
        </div>
      </Modal>
    </>
  )
}
