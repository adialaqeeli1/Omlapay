import {
  useReactTable,
  getCoreRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  flexRender,
  type ColumnDef,
  type SortingState,
  type ColumnFiltersState,
} from '@tanstack/react-table'
import { useState } from 'react'
import clsx from 'clsx'
import { ArrowLeftIcon, ArrowRightIcon } from '../icon'

interface DataTableProps<TData, TValue> {
  columns: ColumnDef<TData, TValue>[]
  data: TData[]
  enablePagination?: boolean
  enableSorting?: boolean
  enableFiltering?: boolean
  className?: string
  /** Server-side pagination: page count from API */
  manualPagination?: boolean
  pageCount?: number
  pageIndex?: number
  onPageChange?: (pageIndex: number) => void
}

export function DataTable<TData, TValue>({
  columns,
  data,
  enablePagination = false,
  enableSorting = true,
  enableFiltering = false,
  className,
  manualPagination = false,
  pageCount: manualPageCount = 1,
  pageIndex: manualPageIndex = 0,
  onPageChange,
}: DataTableProps<TData, TValue>) {
  const [sorting, setSorting] = useState<SortingState>([])
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([])

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel:
      enablePagination && !manualPagination ? getPaginationRowModel() : undefined,
    getSortedRowModel: enableSorting ? getSortedRowModel() : undefined,
    getFilteredRowModel: enableFiltering ? getFilteredRowModel() : undefined,
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    manualPagination,
    pageCount: manualPagination ? manualPageCount : undefined,
    state: {
      sorting,
      columnFilters,
      ...(manualPagination && {
        pagination: { pageIndex: manualPageIndex, pageSize: data.length },
      }),
    },
  })



  return (
    <div
      className={clsx(
        'bg-dark-main rounded-lg overflow-hidden space-y-6',
        className
      )}
    >
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            {table.getHeaderGroups().map(headerGroup => (
              <tr key={headerGroup.id} className="bg-[#191919]">
                {headerGroup.headers.map(header => (
                  <th
                    key={header.id}
                    className={clsx(
                      'p-4 text-left text-sm font-medium text-light-secondary',
                      enableSorting &&
                      header.column.getCanSort() &&
                      'cursor-pointer select-none'
                    )}
                    onClick={
                      enableSorting && header.column.getToggleSortingHandler()
                        ? header.column.getToggleSortingHandler()
                        : undefined
                    }
                  >
                    <div className="flex items-center gap-2 whitespace-nowrap text-light font-roboto font-normal">
                      {header.isPlaceholder
                        ? null
                        : flexRender(
                          header.column.columnDef.header,
                          header.getContext()
                        )}
                      {enableSorting &&
                        header.column.getCanSort() &&
                        (header.column.getIsSorted() === 'asc' ? (
                          <span className="text-primary-main">↑</span>
                        ) : header.column.getIsSorted() === 'desc' ? (
                          <span className="text-primary-main">↓</span>
                        ) : (
                          <span className="text-light-secondary opacity-50">
                            ⇅
                          </span>
                        ))}
                    </div>
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody>
            {table.getRowModel().rows?.length ? (
              table.getRowModel().rows.map(row => (
                <tr
                  key={row.id}
                  className="hover:bg-dark-light transition-colors"
                >
                  {row.getVisibleCells().map(cell => (
                    <td
                      key={cell.id}
                      className="px-4 py-3 text-sm text-light-active"
                    >
                      {flexRender(
                        cell.column.columnDef.cell,
                        cell.getContext()
                      )}
                    </td>
                  ))}
                </tr>
              ))
            ) : (
              <tr>
                <td
                  colSpan={columns.length}
                  className="h-24 text-center text-light-secondary"
                >
                  No results.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
      {enablePagination && (
        <div className="flex items-center justify-end px-6">
          <div className="flex items-center gap-[18px]">
            <button
              onClick={() =>
                manualPagination && onPageChange
                  ? onPageChange(manualPageIndex - 1)
                  : table.previousPage()
              }
              disabled={
                manualPagination
                  ? manualPageIndex <= 0
                  : !table.getCanPreviousPage()
              }
              className="h-[27px] w-[27px] p-1 text-sm text-light-active rounded disabled:opacity-50 disabled:cursor-not-allowed hover:bg-dark-lighter"
            >
              <ArrowRightIcon />
            </button>
            {(() => {
              const currentPage = manualPagination
                ? manualPageIndex + 1
                : table.getState().pagination.pageIndex + 1
              const totalPages = manualPagination
                ? manualPageCount
                : table.getPageCount()
              const pages: (number | 'ellipsis')[] = []

              if (totalPages <= 6) {
                // Show all pages if 6 or fewer
                for (let i = 1; i <= totalPages; i++) {
                  pages.push(i)
                }
              } else {
                const isNearEnd = currentPage >= totalPages - 3

                if (isNearEnd) {
                  // Show: 1 ... (last 4 pages)
                  pages.push(1)
                  if (totalPages - 3 > 2) {
                    pages.push('ellipsis')
                  }
                  for (let i = totalPages - 3; i <= totalPages; i++) {
                    pages.push(i)
                  }
                } else {
                  // Show: 1 ... (4 pages starting from current) ... last
                  if (currentPage <= 4) {
                    // Show first 4 pages if current is in first 4
                    for (let i = 1; i <= 4; i++) {
                      pages.push(i)
                    }
                  } else {
                    // Show: 1 ... (4 pages starting from current) ... last
                    pages.push(1)
                    pages.push('ellipsis')
                    const endPage = Math.min(currentPage + 3, totalPages - 1)
                    for (let i = currentPage; i <= endPage; i++) {
                      pages.push(i)
                    }
                  }
                  if (currentPage <= 4 && totalPages > 5) {
                    pages.push('ellipsis')
                  } else if (currentPage > 4) {
                    const endPage = Math.min(currentPage + 3, totalPages - 1)
                    if (endPage < totalPages - 1) {
                      pages.push('ellipsis')
                    }
                  }
                  pages.push(totalPages)
                }
              }

              return pages.map((page, index) => {
                if (page === 'ellipsis') {
                  return (
                    <span
                      key={`ellipsis-${index}`}
                      className="px-2 text-light-secondary"
                    >
                      ...
                    </span>
                  )
                }
                return (
                  <button
                    key={page}
                    onClick={() =>
                      manualPagination && onPageChange
                        ? onPageChange(page - 1)
                        : table.setPageIndex(page - 1)
                    }
                    className={clsx(
                      'p-1 text-sm rounded min-w-[27px] h-[27px] text-center font-roboto font-normal',
                      currentPage === page
                        ? 'bg-[#050505] text-primary font-medium'
                        : 'text-light-active bg-dark-light hover:bg-dark-lighter'
                    )}
                  >
                    {page}
                  </button>
                )
              })
            })()}
            <button
              onClick={() =>
                manualPagination && onPageChange
                  ? onPageChange(manualPageIndex + 1)
                  : table.nextPage()
              }
              disabled={
                manualPagination
                  ? manualPageIndex >= manualPageCount - 1
                  : !table.getCanNextPage()
              }
              className="h-[27px] w-[27px] p-1 text-sm text-light-active hover:bg-dark-lighter rounded disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <ArrowLeftIcon />
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
