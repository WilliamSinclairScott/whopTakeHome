import React, { useState, useEffect } from 'react';
import axios from 'axios';

interface PrizeWheelProps {
  userId: string;
  wheelId: string;
}

interface SpinResult {
  status: 'pending' | 'won' | 'lost' | 'error';
  prize?: string;
  message?: string;
}

const PrizeWheel: React.FC<PrizeWheelProps> = ({ userId, wheelId }) => {
  const [isSpinning, setIsSpinning] = useState(false);
  const [result, setResult] = useState<SpinResult | null>(null);
  const [spinId, setSpinId] = useState<string | null>(null);
  const [remainingSpins, setRemainingSpins] = useState<number | null>(null);

  const handleSpin = async () => {
    setIsSpinning(true);
    setResult(null);
    setRemainingSpins(prevSpins => prevSpins !== null ? prevSpins - 1 : null);

    try {
      const response = await axios.post('/api/prize_wheel/spin', { user_id: userId, wheel_id: wheelId });
      setResult({ status: 'pending' });
      setSpinId(response.data.spin_job_id);
    } catch (error) {
      setResult({ status: 'error', message: 'An error occurred' });
      setIsSpinning(false);
    }
  };

  useEffect(() => {
    let intervalId: NodeJS.Timeout;

    const pollResult = async () => {
      if (spinId) {
        try {
          const response = await axios.get(`/api/prize_wheel/spin_result/${spinId}`);
          if (response.data.status === 'pending') {
            setResult(response.data);
            setIsSpinning(false);
          }
        } catch (error) {
          setResult({ status: 'error', message: 'An error has occured while ftching the result' });
          setIsSpinning(false);
        }
      }
    };

    if (spinId) {
      intervalId = setInterval(pollResult, 1000);
    }
  }, [spinId]);

  return (
    <div>
      <p>Remaining Spins: {remainingSpins}</p>
      <button onClick={handleSpin} disabled={isSpinning || remainingSpins === 0}>
        {isSpinning ? 'Spinning...' : remainingSpins === 0 ? 'No Spins Left' : 'Spin the Wheel!'}
      </button>
      {result && (
        <div>
          {result.status === 'pending' && <p>Spinning...</p>}
          {result.status === 'won' && <p>Congratulations! You won: {result.prize}</p>}
          {result.status === 'lost' && <p>Sorry, you didn't win anything this time</p>}
          {result.status === 'error' && <p>{result.message}</p>}
        </div>
      )}
    </div>
  );
};

export default PrizeWheel;

//adding for PR to main