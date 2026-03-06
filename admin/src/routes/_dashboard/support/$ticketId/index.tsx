import {
  BackIcon,
  UserIcon,
  MessageIcon,
  AttachmentIcon,
  ImageIcon,
  PdfIcon,
  CreditCardRefreshIcon,
  CheckIcon,
} from '@/components/icon'
import { Checkbox } from '@headlessui/react'
import { createFileRoute, useNavigate } from '@tanstack/react-router'
import clsx from 'clsx'
import Modal from '@/components/common/modal'
import { useState, useEffect } from 'react'
import {
  useGetTicketDetails,
  useAddTicketResponse,
  useUpdateTicketStatus,
  type TicketStatus,
} from '@/api/tickets'
import { format } from 'date-fns'

const STATUS_DISPLAY: Record<TicketStatus, string> = {
  OPEN: 'Open',
  SOLVED: 'Solved',
  REJECTED: 'Rejected',
}

export const Route = createFileRoute('/_dashboard/support/$ticketId/')({
  component: RouteComponent,
})

function RouteComponent() {
  return <SupportTicketDetailsPage />
}

function SupportTicketDetailsPage() {
  const navigate = useNavigate()
  const { ticketId } = Route.useParams()
  const { data, isLoading } = useGetTicketDetails(ticketId)
  const addResponse = useAddTicketResponse(ticketId)
  const updateStatus = useUpdateTicketStatus(ticketId)

  const [isOpen, setIsOpen] = useState(false)
  const [selectedStatus, setSelectedStatus] = useState<TicketStatus>(
    data?.ticket.status ?? 'OPEN'
  )
  const [status, setStatus] = useState<TicketStatus>('OPEN')
  const [responseMessage, setResponseMessage] = useState('')

  useEffect(() => {
    if (data?.ticket.status) {
      setSelectedStatus(data.ticket.status)
      setStatus(data.ticket.status)
    }
  }, [data?.ticket.status])

  const handleClose = () => setIsOpen(false)
  const handleOpen = () => setIsOpen(true)

  const handleConfirmStatus = async () => {
    await updateStatus.mutateAsync({ status })
    setSelectedStatus(status)
    setIsOpen(false)
  }

  const handleAddResponse = async () => {
    if (!responseMessage.trim()) return
    await addResponse.mutateAsync({ message: responseMessage.trim() })
    setResponseMessage('')
  }

  if (isLoading || !data) {
    return (
      <div className="max-w-7xl mx-auto px-5 py-10 flex items-center justify-center">
        <span className="text-light-secondary">Loading...</span>
      </div>
    )
  }

  const { ticket, user, attachments, responses } = data
  const latestAdminResponse = [...responses].reverse().find(r => r.isAdmin)

  return (
    <>
      <div className="max-w-7xl mx-auto px-5 py-10 flex flex-col gap-6 w-full">
        <div className="flex justify-between items-center">
          <button
            onClick={() => navigate({ to: '/support' })}
            className="text-primary-main hover:text-primary-dark text-sm font-medium"
          >
            <BackIcon />
          </button>
          <div className="h-16 p-4 bg-dark-main rounded-[16px] flex items-center gap-4">
            <span className="text-lg font-medium text-light font-poppins">
              Ticket Status{' '}
            </span>
            <div
              onClick={handleOpen}
              className={clsx(
                `w-[120px] h-10 inline-flex items-center justify-center p-2 text-sm font-roboto font-medium rounded-full cursor-pointer`,
                (selectedStatus === 'OPEN' &&
                  'bg-[#2196F31A] text-[#2196F3]') ||
                  (selectedStatus === 'SOLVED' &&
                    'bg-[#14CA741A] text-[#14CA74]') ||
                  (selectedStatus === 'REJECTED' &&
                    'bg-[#F92A2A1A] text-[#F92A2A]')
              )}
            >
              {STATUS_DISPLAY[selectedStatus]}
            </div>
          </div>
        </div>
        <PersonalInformation user={user} />
        <MessageContent title={ticket.title} description={ticket.description} />
        <AttachmentsSection attachments={attachments} />
        {latestAdminResponse ? (
          <ResponseSection
            message={latestAdminResponse.message}
            createdAt={latestAdminResponse.createdAt}
          />
        ) : (
          <AddResponseSection
            message={responseMessage}
            onMessageChange={setResponseMessage}
            onSubmit={handleAddResponse}
            isSubmitting={addResponse.isPending}
          />
        )}
      </div>
      <Modal isOpen={isOpen} onClose={handleClose} maxWidth="max-w-[400px]">
        <div className="flex flex-col gap-5">
          <div className="flex flex-col gap-3">
            <div className="h-12 w-12 rounded-[10px] flex items-center justify-center bg-[#2BA39B3D] text-primary">
              <CreditCardRefreshIcon />
            </div>
            <div className="flex flex-col gap-1">
              <h3 className="text-lg font-inter font-semibold text-light">
                Update Ticket Status
              </h3>
              <p className="text-sm font-inter font-normal text-[#697077]">
                Please update ticket status
              </p>
            </div>
          </div>
          <div className="flex flex-col gap-4">
            {(['OPEN', 'SOLVED', 'REJECTED'] as const).map(s => (
              <div
                key={s}
                onClick={() => setStatus(s)}
                className={clsx(
                  'flex items-center justify-between p-4 rounded-[12px] text-sm font-inter font-medium cursor-pointer ',
                  status === s
                    ? s === 'OPEN'
                      ? 'border-2 border-[#2196F3] bg-[#2196F31F] text-[#2196F3]'
                      : s === 'SOLVED'
                        ? 'border-2 border-[#14CA74] bg-[#14CA741F] text-[#14CA74]'
                        : 'border-2 border-[#F92929] bg-[#F929291F] text-[#F92929]'
                    : 'border border-[#C1C1C1] bg-[#FFFFFF1F] text-light'
                )}
              >
                <span>{STATUS_DISPLAY[s]}</span>
                <Checkbox
                  checked={status === s}
                  className="flex items-center justify-center group block size-4 rounded-full border border-[#D5D7DA] bg-transparent data-checked:bg-[#2196F3] data-checked:border-[#2196F3]"
                >
                  <CheckIcon />
                </Checkbox>
              </div>
            ))}
          </div>
          <div className="flex flex-col gap-3">
            <button
              onClick={handleConfirmStatus}
              disabled={updateStatus.isPending}
              className="h-11 px-4 py-2.5 bg-primary rounded-[6px] text-base font-inter font-semibold text-white disabled:opacity-50"
            >
              {updateStatus.isPending ? 'Updating...' : 'Confirm'}
            </button>
            <button
              onClick={handleClose}
              className="h-11 px-4 py-2.5 bg-[#FFFFFF1F] border border-[#D5D7DA] rounded-[6px] text-base font-inter font-semibold text-light"
            >
              Cancel
            </button>
          </div>
        </div>
      </Modal>
    </>
  )
}

function PersonalInformation({
  user,
}: {
  user: { email: string; phoneNumber: string; fullName: string | null }
}) {
  return (
    <div className="p-4 flex flex-col gap-4 bg-dark-main rounded-[8px]">
      <div className="flex items-center gap-2 h-9">
        <UserIcon />
        <h3 className="text-[22px] font-semibold font-poppins text-primary">
          Personal Information
        </h3>
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div className="col-span-1 flex justify-between items-center py-2.5">
          <span className="w-1/2 text-lg font-medium text-light font-poppins">
            Email
          </span>
          <span className="w-1/2 text-base font-semibold text-light-active">
            {user.email}
          </span>
        </div>
        <div className="col-span-1 flex justify-between items-center py-2.5">
          <span className="w-1/2 text-lg font-medium text-light font-poppins">
            Phone
          </span>
          <span className="w-1/2 text-base font-semibold text-light-active">
            {user.phoneNumber}
          </span>
        </div>
      </div>
    </div>
  )
}

function MessageContent({
  title,
  description,
}: {
  title: string
  description: string
}) {
  return (
    <div className="p-4 flex flex-col gap-4 bg-dark-main rounded-[8px]">
      <div className="flex items-center gap-2 h-9">
        <MessageIcon />
        <h3 className="text-[22px] font-semibold font-poppins text-primary">
          Full Message Content
        </h3>
      </div>
      <div className="px-8 flex flex-col gap-4">
        <div>
          <p className="text-sm font-medium text-light-secondary mb-1">
            {title}
          </p>
          <p className="text-lg font-medium font-poppins text-light-active">
            {description}
          </p>
        </div>
      </div>
    </div>
  )
}

function ResponseSection({
  message,
  createdAt,
}: {
  message: string
  createdAt: string
}) {
  return (
    <div className="p-4 flex flex-col gap-4 bg-dark-main rounded-[8px]">
      <div className="flex items-center gap-2 h-9">
        <MessageIcon />
        <h3 className="text-[22px] font-semibold font-poppins text-primary">
          Response
        </h3>
      </div>
      <div className="px-8 flex flex-col gap-2">
        <p className="text-lg font-medium font-poppins text-light-active">
          {message}
        </p>
        <p className="text-xs text-light-secondary">
          {format(new Date(createdAt), 'dd MMM yyyy, HH:mm')}
        </p>
      </div>
    </div>
  )
}

function AttachmentsSection({
  attachments,
}: {
  attachments: Array<{ url: string; type: 'image' | 'document' }>
}) {
  if (attachments.length === 0) {
    return (
      <div className="p-4 flex flex-col gap-4 bg-dark-main rounded-[8px]">
        <div className="flex items-center gap-2 h-9">
          <AttachmentIcon />
          <h3 className="text-[22px] font-semibold font-poppins text-primary">
            Attachments
          </h3>
        </div>
        <p className="text-light-secondary text-sm">No attachments</p>
      </div>
    )
  }

  return (
    <div className="p-4 flex flex-col gap-4 bg-dark-main rounded-[8px]">
      <div className="flex items-center gap-2 h-9">
        <AttachmentIcon />
        <h3 className="text-[22px] font-semibold font-poppins text-primary">
          Attachments
        </h3>
      </div>
      <div className="flex gap-4 flex-wrap">
        {attachments.map((att, i) => (
          <a
            key={i}
            href={att.url}
            target="_blank"
            rel="noopener noreferrer"
            className="w-12 h-12 bg-[#2AA29A33] rounded-full flex items-center justify-center hover:bg-[#2AA29A4D] transition-colors"
          >
            {att.type === 'image' ? (
              <ImageIcon />
            ) : (
              <PdfIcon />
            )}
          </a>
        ))}
      </div>
    </div>
  )
}

function AddResponseSection({
  message,
  onMessageChange,
  onSubmit,
  isSubmitting,
}: {
  message: string
  onMessageChange: (v: string) => void
  onSubmit: () => void
  isSubmitting: boolean
}) {
  return (
    <div className="p-4 flex flex-col gap-4 bg-dark-main rounded-[8px]">
      <div className="flex items-center gap-2 h-9">
        <MessageIcon />
        <h3 className="text-[22px] font-semibold font-poppins text-primary">
          Add Response
        </h3>
      </div>
      <textarea
        className="w-full h-[256px] p-4 border border-[#252927] rounded-[6px] text-lg font-poppins font-medium text-light-active outline-none bg-transparent"
        placeholder="Add your response here"
        value={message}
        onChange={e => onMessageChange(e.target.value)}
      />
      <div className="flex justify-end">
        <button
          onClick={onSubmit}
          disabled={!message.trim() || isSubmitting}
          className="h-12 px-6 py-1.5 bg-primary rounded-[6px] text-sm font-inter font-bold text-light-active disabled:opacity-50"
        >
          {isSubmitting ? 'Sending...' : 'Add Response'}
        </button>
      </div>
    </div>
  )
}
