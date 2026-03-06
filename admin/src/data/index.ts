// Dummy users data - 100 unique records
export const dummyUsers = Array.from({ length: 100 }, (_, i) => {
  const id = i + 1

  const statuses = [
    'Active',
    'Inactive',
    'Blocked',
    'KYC Pending',
    'KYC Verified',
  ]

  return {
    id: String(id),
    name: `User ${id}`,
    email: `user${id}@example.com`,
    status: statuses[id % statuses.length],
    mainWallet: `0x123456789012345678901234567890123456${String(id).padStart(4, '0')}`,
    balance: 1000 + id * 10,
    createdAt: `2024-01-${String((id % 28) + 1).padStart(2, '0')}`,
  }
})

export const dummyTransactions = Array.from({ length: 100 }, (_, i) => {
  const id = i + 1
  return {
    id: String(id),
    transactionHash: `0x123456789012345678901234567890123456${String(id).padStart(4, '0')}`,
    from: '+905321234567',
    to: '+905321234568',
    amount: 1.25 + id * 10 + ' $',
    currency: 'ETH',
    method: ['Send', 'Receive'][id % 2],
    network: ['Ethereum', 'Bitcoin', 'Tron', 'Solana'][id % 4],
    status: ['Active', 'Failed', 'Pending'][id % 3],
  }
})

export const dummySupportTickets = Array.from({ length: 100 }, (_, i) => {
  const id = i + 1
  return {
    id: String(id),
    title: `Ticket ${id}`,
    description: `Description ${id}`,
    email: `user${id}@example.com`,
    phone: `+905321234567`,
    createdAt: `2024-01-${String((id % 28) + 1).padStart(2, '0')}`,
    status: ['Open', 'Solved', 'Rejected'][id % 3],
  }
})

export const dummyFees = Array.from({ length: 100 }, (_, i) => {
  const id = i + 1
  return {
    id: String(id),
    from_name: `From Name ${id}`,
    to_name: `To Name ${id}`,
    from_email: `from${id}@example.com`,
    to_email: `to${id}@example.com`,
    transactionID: `TXN-2024-${id}`,
    amount: 1.25 + id * 10 + ' $',
    type: ['External Transfer', 'Swap'][id % 2],
    profit: ' $' + (1.25 + id * 10),
  }
})

export const dummyNotifications = Array.from({ length: 100 }, (_, i) => {
  const id = i + 1
  return {
    id: String(id),
    type: ['moderation', 'user_lifecycle', 'support'][id % 3],
    title: `Notification ${id}`,
    description: `A user has been blocked by an administrator for violating terms of service.`,
    createdAt: `2024-01-${String((id % 28) + 1).padStart(2, '0')}, 11:39 AM`, //Jan 15, 2026, 11:39 AM
    isRead: [true, false][id % 2],
  }
})
