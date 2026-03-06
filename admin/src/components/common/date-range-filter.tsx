import { useState } from 'react'
// import { ChevronLeft, ChevronRight, Calendar } from 'lucide-react'
import {
  format,
  addMonths,
  subMonths,
  startOfMonth,
  endOfMonth,
  startOfWeek,
  endOfWeek,
  addDays,
  isSameMonth,
  isSameDay,
  isWithinInterval,
} from 'date-fns'
import clsx from 'clsx'
import {
  Popover,
  PopoverButton,
  PopoverPanel,
  CloseButton,
} from '@headlessui/react'
import { CalendarIcon, RightArrowIcon, LeftArrowIcon } from '@/components/icon'

interface OmlaDateRangePickerProps {
  onConfirm?: (range: { from: Date; to: Date }) => void
  onCancel?: () => void
  initialFrom?: Date
  initialTo?: Date
}

export default function DateRangeFilter({
  onConfirm,
  onCancel,
  initialFrom,
  initialTo,
}: OmlaDateRangePickerProps) {
  const [currentMonth, setCurrentMonth] = useState(initialFrom || new Date())
  const [fromDate, setFromDate] = useState<Date | null>(initialFrom || null)
  const [toDate, setToDate] = useState<Date | null>(initialTo || null)
  const [selectingTo, setSelectingTo] = useState(false)

  // Week starts with Sunday, only show 7 days (S M T W T F S)
  const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S']

  const handlePrevMonth = () => setCurrentMonth(subMonths(currentMonth, 1))
  const handleNextMonth = () => setCurrentMonth(addMonths(currentMonth, 1))

  const handleDateClick = (day: Date) => {
    if (!selectingTo) {
      setFromDate(day)
      setToDate(null)
      setSelectingTo(true)
    } else {
      if (fromDate && day >= fromDate) {
        setToDate(day)
        setSelectingTo(false)
      } else {
        setFromDate(day)
        setToDate(null)
      }
    }
  }

  const handleConfirm = (close: () => void) => {
    if (fromDate && toDate && onConfirm) {
      onConfirm({ from: fromDate, to: toDate })
      close() // Close the popover after confirmation
    }
  }

  const renderDays = () => {
    const monthStart = startOfMonth(currentMonth)
    const monthEnd = endOfMonth(monthStart)
    const startDate = startOfWeek(monthStart, { weekStartsOn: 0 })
    const endDate = endOfWeek(monthEnd, { weekStartsOn: 0 })

    const rows = []
    let days = []
    let day = startDate

    while (day <= endDate) {
      for (let i = 0; i < 7; i++) {
        const cloneDay = day
        const isCurrentMonth = isSameMonth(day, monthStart)
        const isFromSelected = fromDate && isSameDay(day, fromDate)
        const isToSelected = toDate && isSameDay(day, toDate)
        const isSelected = isFromSelected || isToSelected
        const isInRange =
          fromDate &&
          toDate &&
          isWithinInterval(day, { start: fromDate, end: toDate }) &&
          !isSelected
        const isSunday = day.getDay() === 0

        days.push(
          <div
            key={day.toString()}
            className="flex items-center justify-center"
          >
            <button
              onClick={() => handleDateClick(cloneDay)}
              className={clsx(
                'h-7 w-7 rounded-full flex items-center justify-center text-sm font-medium transition-all duration-200',
                !isCurrentMonth && 'text-white opacity-20',
                isCurrentMonth &&
                !isSelected &&
                !isInRange &&
                isSunday &&
                'text-omla-error',
                isCurrentMonth &&
                !isSelected &&
                !isInRange &&
                !isSunday &&
                'text-white hover:bg-primary-main/20',
                isSelected && 'bg-primary-main text-dark-main font-semibold',
                isInRange && 'bg-primary-main/25 text-primary-main'
              )}
            >
              {format(day, 'd')}
            </button>
          </div>
        )
        day = addDays(day, 1)
      }
      rows.push(
        <div key={day.toString()} className="grid grid-cols-7 gap-1">
          {days}
        </div>
      )
      days = []
    }
    return rows
  }

  return (
    <Popover>
      <PopoverButton className="whitespace-nowrap outline-none border border-primary-dark text-primary h-12 px-4 py-2 text-base font-medium font-roboto inline-flex items-center gap-2 rounded-[6px] cursor-pointer">
        <CalendarIcon />
        Filter by date
      </PopoverButton>
      <PopoverPanel
        transition
        anchor="bottom end"
        className="rounded-[24px] bg-[#282828] overflow-hidden transition duration-200 ease-in-out [--anchor-gap:--spacing(5)] data-closed:-translate-y-1 data-closed:opacity-0"
      >
        {({ close }) => (
          <div className="w-auto p-4 flex flex-col gap-5">
            <div className="flex items-center justify-center gap-2">
              <span className="text-white text-base font-medium font-inter">
                From
              </span>
              <div className="flex items-center gap-1.5 px-2.5 py-2 rounded-[10px] border border-primary-main text-primary-main bg-transparent">
                <CalendarIcon className="w-6 h-6" />
                <span className="text-base font-medium font-inter whitespace-nowrap">
                  {fromDate ? format(fromDate, 'd MMMM yyyy') : 'Select date'}
                </span>
              </div>
              <span className="text-white text-base font-medium font-inter">
                To
              </span>
              <div className="flex items-center gap-1.5 px-2.5 py-2 rounded-[10px] border border-primary-main text-primary-main bg-transparent">
                <CalendarIcon className="w-6 h-6" />
                <span className="text-base font-medium font-inter whitespace-nowrap">
                  {toDate ? format(toDate, 'd MMMM yyyy') : 'Select date'}
                </span>
              </div>
            </div>

            {/* Month Navigation */}
            <div className="flex items-center justify-center gap-6">
              <button
                onClick={handlePrevMonth}
                className="text-[#888888] p-1.5 hover:bg-white/5 rounded-full transition-colors"
              >
                <LeftArrowIcon />
              </button>
              <span className="text-white text-[15px] font-medium font-inter min-w-[130px] text-center">
                {format(currentMonth, 'MMMM yyyy')}
              </span>
              <button
                onClick={handleNextMonth}
                className="text-[#888888] p-1.5 hover:bg-white/5 rounded-full transition-colors"
              >
                <RightArrowIcon />
              </button>
            </div>

            <div className="flex flex-col gap-2">
              <div className="grid grid-cols-7 gap-2">
                {weekDays.map((day, index) => (
                  <div
                    key={index}
                    className={clsx(
                      'h-7 w-full flex items-center justify-center text-sm font-medium font-inter text-primary-main'
                    )}
                  >
                    {day}
                  </div>
                ))}
              </div>

              <div className="space-y-2 w-full">{renderDays()}</div>
            </div>

            {/* Action Buttons */}
            <div className="flex items-center justify-end gap-6 px-5 pt-5 pb-3">
              <CloseButton
                onClick={() => {
                  if (onCancel) onCancel()
                  close()
                }}
                className="text-[#B71C1C] text-sm font-medium hover:text-[#B71C1C]/80 transition-colors"
              >
                Cancel
              </CloseButton>
              <button
                onClick={() => handleConfirm(close)}
                disabled={!fromDate || !toDate}
                className={clsx(
                  'text-primary-main text-sm font-medium transition-colors',
                  fromDate && toDate
                    ? 'hover:text-primary-main/80'
                    : 'opacity-50 cursor-not-allowed'
                )}
              >
                OK
              </button>
            </div>
          </div>
        )}
      </PopoverPanel>
    </Popover>
  )
}
