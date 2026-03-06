import { useState, useEffect, useRef } from "react";

type OTPTimerProps = {
    twoFactorOTPexpiryTime: string;
    handleOTPExpiry: () => void;
};

const OTPTimer = ({
    twoFactorOTPexpiryTime,
    handleOTPExpiry,
}: OTPTimerProps) => {
    const [timeLeft, setTimeLeft] = useState(0);
    const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
    const prevTimeLeftRef = useRef(0);

    // Keep the callback ref up-to-date without triggering effect re-runs
    const onExpiryRef = useRef(handleOTPExpiry);
    onExpiryRef.current = handleOTPExpiry;

    useEffect(() => {
        if (intervalRef.current) {
            clearInterval(intervalRef.current);
            intervalRef.current = null;
        }

        const expiryTimeMs = Number(twoFactorOTPexpiryTime);
        if (!expiryTimeMs || expiryTimeMs <= 0) {
            setTimeLeft(0);
            return;
        }

        const remainingMs = expiryTimeMs - Date.now();
        const remainingSeconds = Math.max(Math.ceil(remainingMs / 1000), 0);

        if (remainingSeconds <= 0) {
            setTimeLeft(0);
            onExpiryRef.current();
            return;
        }

        setTimeLeft(remainingSeconds);

        intervalRef.current = setInterval(() => {
            setTimeLeft((prev) => {
                if (prev <= 1) {
                    if (intervalRef.current) {
                        clearInterval(intervalRef.current);
                        intervalRef.current = null;
                    }
                    return 0;
                }
                return prev - 1;
            });
        }, 1000);

        return () => {
            if (intervalRef.current) {
                clearInterval(intervalRef.current);
                intervalRef.current = null;
            }
        };
    }, [twoFactorOTPexpiryTime]);

    // Fire expiry only when timeLeft transitions from >0 to 0 (actual countdown completion)
    useEffect(() => {
        if (timeLeft === 0 && prevTimeLeftRef.current > 0) {
            onExpiryRef.current();
        }
        prevTimeLeftRef.current = timeLeft;
    }, [timeLeft]);

    const formatTime = (seconds: number): string => {
        const m = Math.floor(seconds / 60);
        const s = seconds % 60;
        return `${m}:${s < 10 ? "0" : ""}${s}`;
    };

    if (timeLeft <= 0) return null;

    return (
        <span className="">
            {formatTime(timeLeft)}
        </span>
    );
};

export default OTPTimer;
