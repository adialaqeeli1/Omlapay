// import { createRoute } from '@tanstack/react-router'
// import { Route as rootRoute } from './__root'

// export const Route = createRoute({
//   getParentRoute: () => rootRoute,
//   path: '/',
//   component: Index,
// })

// function Index() {
//   return (
//     <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
//       <div className="px-4 py-6 sm:px-0">
//         <h2 className="text-2xl font-bold text-gray-900">Home</h2>
//       </div>
//     </div>
//   )
// }
import { createFileRoute, redirect } from '@tanstack/react-router'
import { useAuthStore } from '../stores/useStore'

export const Route = createFileRoute('/')({
  beforeLoad: () => {
    const isAuthenticated = useAuthStore.getState().isAuthenticated
    if (isAuthenticated) {
      throw redirect({ to: '/dashboard' })
    } else {
      throw redirect({ to: '/login' })
    }
  },
  component: () => null, // Never renders - always redirects in beforeLoad
})
