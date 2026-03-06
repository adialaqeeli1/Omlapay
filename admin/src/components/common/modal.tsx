import React, { useRef, useEffect } from 'react'
import { CloseIcon } from '@/components/icon'

interface ModalProps {
  isOpen: boolean
  onClose?: () => void
  children: React.ReactNode
  maxWidth?: string
}

const Modal: React.FC<ModalProps> = ({
  isOpen,
  onClose,
  children,
  maxWidth = 'max-w-xl',
}) => {
  const contentRef = useRef<HTMLDivElement>(null)

  const handleOverlayClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (contentRef.current && !contentRef.current.contains(e.target as Node)) {
      onClose?.()
    }
  }

  // Prevent body scroll when modal is open
  useEffect(() => {
    if (isOpen) {
      document.body.classList.add('overflow-hidden')
    } else {
      document.body.classList.remove('overflow-hidden')
    }
    // Clean up when modal unmounts
    return () => {
      document.body.classList.remove('overflow-hidden')
    }
  }, [isOpen])

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-50" onMouseDown={handleOverlayClick}>
      <div className="fixed inset-0 bg-gray-500/25 transition-opacity" />
      <div className="fixed inset-0 w-screen overflow-y-auto">
        <div className="flex min-h-full items-center justify-center p-4 text-center">
          <div
            ref={contentRef}
            onMouseDown={e => e.stopPropagation()}
            className={`relative transform overflow-hidden rounded-[16px] bg-dark-main text-left shadow-[0px_8px_8px_-4px_#0A0D120A] transition-all p-6 w-full z-[1005] ${maxWidth}`}
          >
            {onClose && (
              <button
                onClick={onClose}
                className="absolute top-4 right-4 z-10 p-1 rounded-full cursor-pointer transition-colors"
                aria-label="Close modal"
              >
                <CloseIcon className="w-[14px] h-[14px] text-[#717680]" />
              </button>
            )}
            {children}
          </div>
        </div>
      </div>
    </div>
  )
}

export default Modal

// box-shadow: 0px 8px 8px -4px #0A0D120A;

// box-shadow: 0px 20px 24px -4px #0A0D121A;
