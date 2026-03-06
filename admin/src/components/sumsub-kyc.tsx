import { useEffect, useRef, useState } from 'react'
import snsWebSdk from '@sumsub/websdk'
import { startKycVerification, getKycStatus, startBinanceKyc, type StartKycData } from '@/lib/api'

/**
 * Filter out empty strings - backend DTO expects optional fields, empty strings can fail validation.
 * NOTE: If SumSub dashboard shows only first name: configure the verification level's Applicant data
 * step to use separate "First name" and "Last name" fields (not just "Full name").
 * Dashboard → Settings → Levels → [your level] → Applicant data step.
 */
function toKycPayload(data: StartKycData): StartKycData {
  const payload: StartKycData = {}
  if (data.firstName?.trim()) payload.firstName = data.firstName.trim()
  if (data.lastName?.trim()) payload.lastName = data.lastName.trim()
  if (data.dob?.trim()) payload.dob = data.dob.trim()
  if (data.residentialCountry?.trim()) payload.residentialCountry = data.residentialCountry.trim().toUpperCase()
  if (data.country?.trim()) payload.country = data.country.trim().toUpperCase()
  if (data.address?.trim()) payload.address = data.address.trim()
  if (data.city?.trim()) payload.city = data.city.trim()
  return payload
}

export default function SumsubKyc() {
  const containerRef = useRef<HTMLDivElement>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [status, setStatus] = useState<any>(null)
  const sdkInstanceRef = useRef<any>(null)
  const [showForm, setShowForm] = useState(true)
  /** Manual Bearer token for testing - use when VITE_TEST_JWT_TOKEN or stored tokens are not set */
  const [bearerToken, setBearerToken] = useState('')
  const [formData, setFormData] = useState<StartKycData>({
    firstName: '',
    lastName: '',
    residentialCountry: '',
    dob: '',
    country: '',
    address: '',
    city: '',
  })

  const resolveAuthToken = (): string | null => bearerToken?.trim() || null

  const initSumsub = async (kycData: StartKycData) => {
    try {
      setLoading(true)
      setError(null)

      const authToken = resolveAuthToken()
      if (!authToken) {
        setError('Paste a user Bearer token in the field below (from app login)')
        setLoading(false)
        return
      }

      const payload = toKycPayload(kycData)
      const tokenData = await startKycVerification(authToken, payload).catch((err) => {
        console.error('Error starting KYC:', err)
        throw err
      })

      if (!tokenData?.token) {
        throw new Error(`Failed to get access token. Response: ${JSON.stringify(tokenData)}`)
      }

      if (!containerRef.current) {
        throw new Error('Container element not found')
      }

      const getNewAccessToken = async () => {
        const auth = resolveAuthToken()
        if (!auth) return ''
        const newTokenData = await startKycVerification(auth, payload)
        return newTokenData?.token || ''
      }

      const snsWebSdkInstance = snsWebSdk
        .init(tokenData.token, getNewAccessToken)
        .withConf({
          lang: 'en',
          theme: 'dark',
          ...(payload.country && { country: payload.country }),
        })
        .withOptions({
          addViewportTag: false,
          adaptIframeHeight: true,
        })
        .on('idCheck.onStepCompleted', (payload: any) => {
          console.log('Step completed:', payload)
        })
        .on('idCheck.onError', (error: any) => {
          console.error('Sumsub SDK error:', error)
          setError(error?.message || 'An error occurred during verification')
        })
        .onMessage((type: string, payload: any) => {
          if (type === 'idCheck.onApplicantSubmitted') {
            console.log('Applicant submitted:', payload)
          }
        })
        .build()

      sdkInstanceRef.current = snsWebSdkInstance
      snsWebSdkInstance.launch(containerRef.current)
      setLoading(false)
      setShowForm(false)
    } catch (err: any) {
      console.error('Sumsub setup error:', err)
      setError(err?.message || err?.toString() || 'Failed to setup Sumsub KYC')
      setLoading(false)
    }
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    initSumsub(formData)
  }

  useEffect(() => {
    return () => {
      if (sdkInstanceRef.current) {
        try {
          if (typeof sdkInstanceRef.current.destroy === 'function') {
            sdkInstanceRef.current.destroy()
          }
        } catch (e) {
          console.warn('Error cleaning up Sumsub SDK:', e)
        }
        sdkInstanceRef.current = null
      }
    }
  }, [])

  const handleCheckStatus = async () => {
    try {
      setLoading(true)
      setError(null)
      const authToken = resolveAuthToken()
      if (!authToken) {
        setError('Paste a user Bearer token in the field above.')
        setLoading(false)
        return
      }
      const kycStatus = await getKycStatus(authToken)
      setStatus(kycStatus)
      setLoading(false)
    } catch (err: any) {
      setError(err.message || 'Failed to get KYC status')
      setLoading(false)
    }
  }

  const handleStartBinanceKyc = async () => {
    try {
      setLoading(true)
      setError(null)
      const authToken = resolveAuthToken()
      if (!authToken) {
        setError('Paste a user Bearer token in the field above.')
        setLoading(false)
        return
      }
      await startBinanceKyc(authToken)
      const kycStatus = await getKycStatus(authToken)
      setStatus(kycStatus)
    } catch (err: any) {
      setError(err?.message || 'Failed to start Binance KYC')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="bg-dark-main rounded-lg p-6">
      <div className="flex justify-between items-center mb-4">
        <h3 className="text-xl font-semibold text-light-main">Sumsub KYC Verification</h3>
        <button
          onClick={handleCheckStatus}
          disabled={loading}
          className="px-4 py-2 bg-primary text-white rounded hover:bg-primary-dark disabled:opacity-50"
        >
          Check Status
        </button>
      </div>

      {error && (
        <div className="mb-4 p-4 bg-red-500/10 border border-red-500 rounded text-red-400">
          <div className="font-semibold mb-2">Error:</div>
          <div>{error}</div>
        </div>
      )}

      <div className="mb-4 p-4 bg-dark-secondary border border-gray-700 rounded">
        <label className="block text-sm font-medium text-light-secondary mb-2">
          User Bearer Token (for testing)
        </label>
        <input
          type="password"
          placeholder="Paste user JWT from app login"
          value={bearerToken}
          onChange={(e) => setBearerToken(e.target.value)}
          className="w-full px-3 py-2 bg-dark-main border border-gray-700 rounded text-black focus:outline-none focus:border-primary text-sm font-mono"
        />
        <p className="mt-2 text-xs text-light-secondary">
          KYC endpoints require a <strong>user</strong> JWT (from app auth), not admin. Log in via the app API and paste
          the access token here.
        </p>
      </div>

      {showForm && (
        <form onSubmit={handleSubmit} className="space-y-4 mb-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-light-secondary mb-1">
                First Name *
              </label>
              <input
                type="text"
                required
                value={formData.firstName}
                onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
                className="w-full px-3 py-2 bg-dark-secondary border border-gray-700 rounded text-black focus:outline-none focus:border-primary"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-light-secondary mb-1">
                Last Name *
              </label>
              <input
                type="text"
                required
                value={formData.lastName}
                onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
                className="w-full px-3 py-2 bg-dark-secondary border border-gray-700 rounded text-black focus:outline-none focus:border-primary"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-light-secondary mb-1">
                Date of Birth *
              </label>
              <input
                type="date"
                required
                value={formData.dob}
                onChange={(e) => setFormData({ ...formData, dob: e.target.value })}
                className="w-full px-3 py-2 bg-dark-secondary border border-gray-700 rounded text-black focus:outline-none focus:border-primary"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-light-secondary mb-1">
                Residential Country (ISO 3166-1 alpha-3) *
              </label>
              <input
                type="text"
                required
                maxLength={3}
                placeholder="e.g., GBR, USA, IND"
                value={formData.residentialCountry}
                onChange={(e) => setFormData({ ...formData, residentialCountry: e.target.value.toUpperCase() })}
                className="w-full px-3 py-2 bg-dark-secondary border border-gray-700 rounded text-black focus:outline-none focus:border-primary"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-light-secondary mb-1">
                Document Country (ISO 3166-1 alpha-3) *
              </label>
              <input
                type="text"
                required
                maxLength={3}
                placeholder="e.g., GBR, USA, IND"
                value={formData.country}
                onChange={(e) => setFormData({ ...formData, country: e.target.value.toUpperCase() })}
                className="w-full px-3 py-2 bg-dark-secondary border border-gray-700 rounded text-black focus:outline-none focus:border-primary"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-light-secondary mb-1">
                City *
              </label>
              <input
                type="text"
                required
                value={formData.city}
                onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                className="w-full px-3 py-2 bg-dark-secondary border border-gray-700 rounded text-black focus:outline-none focus:border-primary"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-light-secondary mb-1">
              Address *
            </label>
            <input
              type="text"
              required
              value={formData.address}
              onChange={(e) => setFormData({ ...formData, address: e.target.value })}
              className="w-full px-3 py-2 bg-dark-secondary border border-gray-700 rounded text-black focus:outline-none focus:border-primary"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full px-6 py-3 bg-primary text-white rounded-lg hover:bg-primary-dark transition-colors font-medium disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? 'Starting KYC...' : 'Start KYC Verification'}
          </button>
        </form>
      )}

      {loading && !error && !showForm && (
        <div className="mb-4 p-4 bg-blue-500/10 border border-blue-500 rounded text-blue-400">
          Loading Sumsub KYC widget...
        </div>
      )}

      <div
        ref={containerRef}
        id="sumsub-websdk-container"
        className="w-full"
        style={{ minHeight: showForm ? '0px' : '600px' }}
      />

      {status?.binance?.canStart && (
        <div className="mt-4 p-4 bg-amber-500/10 border border-amber-500 rounded">
          <p className="text-amber-400 mb-2">Sumsub KYC approved. You can now complete Binance KYC.</p>
          <button
            type="button"
            onClick={handleStartBinanceKyc}
            disabled={loading}
            className="px-4 py-2 bg-amber-600 text-white rounded hover:bg-amber-700 disabled:opacity-50"
          >
            {loading ? 'Submitting...' : 'Start Binance KYC'}
          </button>
        </div>
      )}

      {status && (
        <div className="mt-4 p-4 bg-green-500/10 border border-green-500 rounded">
          <h4 className="text-green-400 font-semibold mb-2">KYC Status:</h4>
          <pre className="text-xs text-light-secondary overflow-auto max-h-96">
            {JSON.stringify(status, null, 2)}
          </pre>
        </div>
      )}
    </div>
  )
}
