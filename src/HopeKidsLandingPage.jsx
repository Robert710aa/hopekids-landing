import { useCallback, useEffect, useId, useState } from 'react';

// HKIDS token mint on Solana (Jupiter swap)
const HKIDS_MINT = '6u5PLy9ePpuGEBK3kmQ9isVDFjqSurKpvmCFzheDgQke';
const JUPITER_BUY_URL = `https://jup.ag/swap/SOL-${HKIDS_MINT}`;
const DEXSCREENER_TOKEN_URL = `https://api.dexscreener.com/latest/dex/tokens/${HKIDS_MINT}`;
/** DexScreener token page shows holders; public API JSON does not include holder count. */
const DEXSCREENER_TOKEN_PAGE = `https://dexscreener.com/solana/${HKIDS_MINT}`;
const SOLSCAN_TOKEN_URL = `https://solscan.io/token/${HKIDS_MINT}`;

/** Social links — replace # with official profiles when ready */
const SOCIAL_TWITTER_URL = '#';
const SOCIAL_INSTAGRAM_URL = '#';
const SOCIAL_TIKTOK_URL = '#';

/** Public donation wallet (Solana) */
const PUBLIC_DONATION_WALLET = 'GnhmPt4LBHRoABuGrSqrbPW34Mu8dXGJf1XCNc7DHRAB';

/** HopeKids team inbox */
const HOPEKIDS_TEAM_EMAIL = 'hopekids594@gmail.com';

const FALLBACK_MARKET_CAP = '$3,250,000';

/** Cinematic hero art: token, child, hospital + space — swap file in public/ to update. */
const HERO_ILLUSTRATION_SRC = '/hopekids-hero-illustration.png';

/** Example spotlight in Fundraiser panel — replace image in public/ or name as needed. */
const SPOTLIGHT_CHILD_IMAGE_SRC = '/hopekids-spotlight-child.jpg';
const SPOTLIGHT_CHILD_NAME = 'Sofia M.';

const SPOTLIGHT_WINDOW_MS = 30 * 24 * 60 * 60 * 1000;
const SPOTLIGHT_DEADLINE_STORAGE_KEY = 'hopekids-spotlight-deadline-ms';

function ensureSpotlightDeadlineMs() {
  if (typeof window === 'undefined') return Date.now() + SPOTLIGHT_WINDOW_MS;
  try {
    const raw = window.localStorage.getItem(SPOTLIGHT_DEADLINE_STORAGE_KEY);
    if (raw) {
      const t = parseInt(raw, 10);
      if (Number.isFinite(t)) {
        if (t > Date.now()) return t;
        const next = Date.now() + SPOTLIGHT_WINDOW_MS;
        window.localStorage.setItem(SPOTLIGHT_DEADLINE_STORAGE_KEY, String(next));
        return next;
      }
    }
    const end = Date.now() + SPOTLIGHT_WINDOW_MS;
    window.localStorage.setItem(SPOTLIGHT_DEADLINE_STORAGE_KEY, String(end));
    return end;
  } catch {
    return Date.now() + SPOTLIGHT_WINDOW_MS;
  }
}

function useSpotlightCountdown() {
  const [endMs, setEndMs] = useState(() => Date.now() + SPOTLIGHT_WINDOW_MS);
  const [now, setNow] = useState(() => Date.now());

  useEffect(() => {
    setEndMs(ensureSpotlightDeadlineMs());
  }, []);

  useEffect(() => {
    const id = window.setInterval(() => {
      const t = Date.now();
      setNow(t);
      setEndMs((prev) => {
        if (t >= prev) {
          const next = t + SPOTLIGHT_WINDOW_MS;
          try {
            window.localStorage.setItem(SPOTLIGHT_DEADLINE_STORAGE_KEY, String(next));
          } catch {
            /* private mode */
          }
          return next;
        }
        return prev;
      });
    }, 1000);
    return () => window.clearInterval(id);
  }, []);

  const remaining = Math.max(0, endMs - now);
  const hours = Math.floor(remaining / 3_600_000);
  const minutes = Math.floor((remaining % 3_600_000) / 60_000);
  const seconds = Math.floor((remaining % 60_000) / 1000);
  return { hours, minutes, seconds, remaining };
}

/** Earth seen from space — pairs with public/favicon.svg */
function HopeKidsBrandMark({ className = 'h-9 w-9 sm:h-10 sm:w-10' }) {
  const uid = useId().replace(/:/g, '');
  const space = `hks-${uid}`;
  const ocean = `hko-${uid}`;
  const clip = `hkc-${uid}`;
  return (
    <svg
      viewBox="0 0 48 48"
      className={className}
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
    >
      <defs>
        <linearGradient id={space} x1="4" y1="2" x2="44" y2="46" gradientUnits="userSpaceOnUse">
          <stop stopColor="#020617" />
          <stop offset="0.55" stopColor="#0f172a" />
          <stop offset="1" stopColor="#020617" />
        </linearGradient>
        <radialGradient id={ocean} cx="22" cy="20" r="17" gradientUnits="userSpaceOnUse">
          <stop stopColor="#bae6fd" />
          <stop offset="0.28" stopColor="#38bdf8" />
          <stop offset="0.55" stopColor="#0284c7" />
          <stop offset="0.85" stopColor="#075985" />
          <stop offset="1" stopColor="#0c4a6e" />
        </radialGradient>
        <clipPath id={clip}>
          <circle cx="24" cy="24" r="13" />
        </clipPath>
      </defs>
      <rect width="48" height="48" rx="14" fill={`url(#${space})`} />
      <circle cx="9" cy="11" r="0.65" fill="#e2e8f0" opacity="0.5" />
      <circle cx="39" cy="9" r="0.5" fill="#fff" opacity="0.38" />
      <circle cx="41" cy="36" r="0.45" fill="#cbd5e1" opacity="0.32" />
      <g clipPath={`url(#${clip})`}>
        <circle cx="24" cy="24" r="13" fill={`url(#${ocean})`} />
        <ellipse cx="21" cy="20" rx="6.2" ry="4.8" fill="#15803d" opacity="0.9" transform="rotate(-22 21 20)" />
        <ellipse cx="29" cy="25.5" rx="4.2" ry="5.8" fill="#166534" opacity="0.92" transform="rotate(15 29 25.5)" />
        <ellipse cx="16.5" cy="26" rx="3.8" ry="5.2" fill="#14532d" opacity="0.85" transform="rotate(-10 16.5 26)" />
      </g>
      <circle cx="24" cy="24" r="13" fill="none" stroke="rgba(125, 211, 252, 0.5)" strokeWidth="0.75" />
      <circle cx="24" cy="24" r="14.8" fill="none" stroke="rgba(56, 189, 248, 0.16)" strokeWidth="1.8" />
      <rect x="0.5" y="0.5" width="47" height="47" rx="13.5" stroke="rgba(251, 191, 36, 0.24)" />
    </svg>
  );
}

function IconTwitterX({ className = 'h-5 w-5' }) {
  return (
    <svg viewBox="0 0 24 24" className={className} fill="currentColor" aria-hidden="true">
      <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
    </svg>
  );
}

function IconInstagram({ className = 'h-5 w-5' }) {
  return (
    <svg viewBox="0 0 24 24" className={className} fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
      <rect x="3" y="3" width="18" height="18" rx="5" />
      <circle cx="12" cy="12" r="3.5" />
      <circle cx="17.5" cy="6.5" r="1" fill="currentColor" stroke="none" />
    </svg>
  );
}

function IconTikTok({ className = 'h-5 w-5' }) {
  return (
    <svg viewBox="0 0 24 24" className={className} fill="currentColor" aria-hidden="true">
      <path d="M19.59 6.69a4.83 4.83 0 01-3.77-4.25V2h-3.45v13.67a2.89 2.89 0 01-5.2 1.74 2.89 2.89 0 012.31-4.64 2.93 2.93 0 01.88.13V9.4a6.84 6.84 0 00-1-.05A6.33 6.33 0 005 20.1a6.34 6.34 0 0010.86-4.43v-7a8.16 8.16 0 004.77 1.52v-3.4a4.85 4.85 0 01-1-.1z" />
    </svg>
  );
}

/** DexScreener-style mark: emerald tile + chart stroke (brand-adjacent, not official artwork). */
function IconDexScreener({ className = 'h-5 w-5' }) {
  return (
    <svg viewBox="0 0 24 24" className={className} aria-hidden="true">
      <rect width="24" height="24" rx="5" fill="#10b981" />
      <path
        d="M6 16l4-4.5 3 2.5 5-6"
        fill="none"
        stroke="#ecfdf5"
        strokeWidth="1.85"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function pickBestPair(pairs) {
  if (!pairs?.length) return null;
  return [...pairs].sort((a, b) => (b.liquidity?.usd ?? 0) - (a.liquidity?.usd ?? 0))[0];
}

function formatUsdCompact(n) {
  if (n == null || Number.isNaN(n) || !Number.isFinite(Number(n))) return null;
  const x = Number(n);
  if (x >= 1e9) return `$${(x / 1e9).toFixed(2)}B`;
  if (x >= 1e6) return `$${(x / 1e6).toFixed(2)}M`;
  if (x >= 1e3) return `$${(x / 1e3).toFixed(2)}K`;
  return `$${x.toFixed(2)}`;
}

function formatPriceUsd(raw) {
  const x = typeof raw === 'string' ? parseFloat(raw) : raw;
  if (!Number.isFinite(x)) return null;
  if (x >= 1) return `$${x.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  if (x >= 0.01) return `$${x.toFixed(4)}`;
  return `$${x.toPrecision(4)}`;
}

export default function HopeKidsLandingPage() {
  const [storyOpen, setStoryOpen] = useState(false);
  const [walletCopied, setWalletCopied] = useState(false);
  const spotlightCountdown = useSpotlightCountdown();

  const copyDonationWallet = useCallback(async () => {
    try {
      await navigator.clipboard.writeText(PUBLIC_DONATION_WALLET);
      setWalletCopied(true);
      window.setTimeout(() => setWalletCopied(false), 2000);
    } catch {
      /* no permission / clipboard unsupported */
    }
  }, []);

  useEffect(() => {
    if (!storyOpen) return;
    const onKey = (e) => {
      if (e.key === 'Escape') setStoryOpen(false);
    };
    window.addEventListener('keydown', onKey);
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      window.removeEventListener('keydown', onKey);
      document.body.style.overflow = prev;
    };
  }, [storyOpen]);

  const [tokenStats, setTokenStats] = useState({
    loading: true,
    marketCapUsd: null,
    priceUsd: null,
    liquidityUsd: null,
    dexscreenerUrl: DEXSCREENER_TOKEN_PAGE,
  });

  useEffect(() => {
    let cancelled = false;
    const ac = new AbortController();

    async function load() {
      let mcap = null;
      let price = null;
      let liq = null;
      let dexUrl = DEXSCREENER_TOKEN_PAGE;

      try {
        const res = await fetch(DEXSCREENER_TOKEN_URL, { signal: ac.signal });
        if (res.ok) {
          const dexData = await res.json();
          const pairs = dexData?.pairs;
          if (Array.isArray(pairs) && pairs.length > 0) {
            const pair = pickBestPair(pairs);
            const mcapRaw = pair?.marketCap ?? pair?.fdv;
            const m = mcapRaw != null ? Number(mcapRaw) : null;
            mcap = Number.isFinite(m) ? m : null;
            price = pair?.priceUsd != null ? formatPriceUsd(pair.priceUsd) : null;
            liq = pair?.liquidity?.usd != null ? formatUsdCompact(pair.liquidity.usd) : null;
            if (pair?.url) dexUrl = pair.url;
          }
        }
      } catch {
        /* network / abort */
      }

      if (!cancelled) {
        setTokenStats({
          loading: false,
          marketCapUsd: mcap,
          priceUsd: price,
          liquidityUsd: liq,
          dexscreenerUrl: dexUrl,
        });
      }
    }

    load();
    const t = setInterval(load, 90_000);
    return () => {
      cancelled = true;
      ac.abort();
      clearInterval(t);
    };
  }, []);

  const stats = [
    { label: 'Tokens Saved for Children', value: '2,350,000', suffix: 'HKIDS' },
    { label: 'Current Value', value: '$14,200', suffix: '' },
    { label: 'Total Transactions Helping Children', value: '9,482', suffix: '' },
  ];

  return (
    <>
      <style>{`
        @keyframes float {
          0%, 100% { transform: translateY(0px); }
          50% { transform: translateY(-10px); }
        }

        @keyframes coinRotate {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }

        @keyframes shineSweep {
          0% { transform: translateX(-180%) rotate(18deg); opacity: 0; }
          20% { opacity: 0; }
          45% { opacity: 0.75; }
          70% { opacity: 0; }
          100% { transform: translateX(220%) rotate(18deg); opacity: 0; }
        }

        @keyframes hopekids-title-shimmer {
          0%, 100% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
        }

        @keyframes hopekids-aurora-drift {
          0%, 100% { transform: translate(0, 0) scale(1); opacity: 0.45; }
          50% { transform: translate(6%, -8%) scale(1.08); opacity: 0.8; }
        }

        @keyframes hopekids-star-twinkle {
          0%, 100% { opacity: 0.25; transform: scale(1); }
          50% { opacity: 0.95; transform: scale(1.35); }
        }

        @keyframes hopekids-hero-sheen-move {
          0%, 100% { background-position: 130% 50%; }
          50% { background-position: -30% 50%; }
        }

        .hopekids-title-glare {
          background: linear-gradient(
            105deg,
            #fcd34d 0%,
            #fbbf24 20%,
            #fef3c7 45%,
            #f59e0b 55%,
            #fcd34d 100%
          );
          background-size: 200% auto;
          -webkit-background-clip: text;
          background-clip: text;
          color: transparent;
          animation: hopekids-title-shimmer 8s ease-in-out infinite;
        }

        .hopekids-aurora-a {
          animation: hopekids-aurora-drift 20s ease-in-out infinite;
        }

        .hopekids-aurora-b {
          animation: hopekids-aurora-drift 26s ease-in-out infinite reverse;
          animation-delay: -8s;
        }

        .hopekids-hero-sheen {
          background: linear-gradient(
            118deg,
            transparent 0%,
            rgba(56, 189, 248, 0.12) 42%,
            rgba(251, 191, 36, 0.06) 50%,
            transparent 58%
          );
          background-size: 240% 240%;
          animation: hopekids-hero-sheen-move 14s ease-in-out infinite;
        }

        /* Hero panel — match cinematic art: space blues + token gold wash */
        .hopekids-cinema-sheen {
          background: linear-gradient(
            122deg,
            transparent 0%,
            rgba(251, 191, 36, 0.12) 38%,
            rgba(254, 243, 199, 0.08) 49%,
            rgba(59, 130, 246, 0.06) 54%,
            transparent 62%
          );
          background-size: 260% 260%;
          animation: hopekids-hero-sheen-move 18s ease-in-out infinite;
        }

        .hopekids-star {
          animation: hopekids-star-twinkle 3.2s ease-in-out infinite;
          box-shadow: 0 0 8px rgba(165, 243, 252, 0.6);
        }

        @media (prefers-reduced-motion: reduce) {
          .hopekids-title-glare,
          .hopekids-aurora-a,
          .hopekids-aurora-b,
          .hopekids-hero-sheen,
          .hopekids-cinema-sheen,
          .hopekids-star {
            animation: none !important;
          }
          .hopekids-title-glare {
            background-position: 50% 50%;
          }
        }
      `}</style>

      <div className="relative min-h-screen bg-transparent text-white">
        <div className="relative z-10 min-h-screen overflow-x-hidden">
          <div className="mx-auto max-w-[1180px] px-4 pb-8 pt-2 sm:px-6 lg:px-8">
            {/* Full-bleed artwork: entire upper panel = one scene (nav + hero on top of art) */}
            <div className="relative min-h-[min(78vh,720px)] overflow-hidden rounded-2xl border border-amber-500/25 shadow-[0_0_80px_rgba(251,191,36,0.1),0_30px_70px_-20px_rgba(0,0,0,0.8),inset_0_1px_0_rgba(255,250,235,0.05)] sm:min-h-[min(74vh,640px)] sm:rounded-[28px]">
              <img
                src={HERO_ILLUSTRATION_SRC}
                alt=""
                className="pointer-events-none absolute inset-0 h-full w-full object-cover object-[52%_center] sm:object-[48%_center] lg:object-[46%_center]"
                loading="eager"
                decoding="async"
                aria-hidden="true"
              />
              {/* Readability: dark veil on left (copy + nav), lighter toward art on the right */}
              <div
                className="pointer-events-none absolute inset-0 bg-[linear-gradient(105deg,rgba(3,5,12,0.93)_0%,rgba(3,8,20,0.72)_28%,rgba(5,10,22,0.35)_52%,transparent_76%)] sm:bg-[linear-gradient(105deg,rgba(3,5,12,0.94)_0%,rgba(3,8,20,0.68)_26%,rgba(5,12,28,0.28)_50%,transparent_74%)]"
                aria-hidden="true"
              />
              <div
                className="pointer-events-none absolute inset-0 bg-[linear-gradient(180deg,rgba(2,4,10,0.82)_0%,transparent_35%,transparent_58%,rgba(2,4,10,0.55)_100%)]"
                aria-hidden="true"
              />
              <div
                className="pointer-events-none absolute inset-0 overflow-hidden rounded-2xl sm:rounded-[28px]"
                aria-hidden="true"
              >
                <div className="hopekids-cinema-sheen absolute inset-0 opacity-[0.18]" />
              </div>

              <header className="sticky top-2 z-50 flex flex-wrap items-center justify-center gap-3 border-b border-amber-400/15 bg-[rgba(2,4,12,0.55)] px-4 py-2.5 shadow-[0_12px_40px_rgba(0,0,0,0.35)] backdrop-blur-md sm:px-6 sm:py-3 lg:px-10">
              <nav
                className="flex flex-wrap items-center justify-center gap-3 text-sm font-semibold text-stone-100/95 drop-shadow-[0_1px_10px_rgba(0,0,0,0.85)] sm:gap-4"
                aria-label="Social and charts"
              >
                <a
                  href={SOCIAL_TWITTER_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 transition hover:text-amber-50"
                  aria-label="Twitter"
                >
                  <IconTwitterX className="h-5 w-5 shrink-0 text-slate-100" />
                  <span className="hidden md:inline">Twitter</span>
                </a>
                <a
                  href={SOCIAL_INSTAGRAM_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 transition hover:text-amber-50"
                  aria-label="Instagram"
                >
                  <IconInstagram className="h-5 w-5 shrink-0 text-pink-200" />
                  <span className="hidden md:inline">Instagram</span>
                </a>
                <a
                  href={SOCIAL_TIKTOK_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 transition hover:text-amber-50"
                  aria-label="TikTok"
                >
                  <IconTikTok className="h-5 w-5 shrink-0 text-cyan-200" />
                  <span className="hidden md:inline">TikTok</span>
                </a>
                <a
                  href={tokenStats.dexscreenerUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 transition hover:text-amber-50"
                  aria-label="DexScreener"
                >
                  <IconDexScreener className="h-5 w-5 shrink-0" />
                  <span className="hidden md:inline">DexScreener</span>
                </a>
              </nav>
              </header>

              <section
                id="home"
                aria-label="HopeKids introduction"
                className="relative z-10 border-0 bg-transparent px-4 py-7 shadow-none sm:px-6 sm:py-9 lg:px-10 lg:pb-11 lg:pt-9"
              >
                <div className="relative z-10 mx-auto flex max-w-xl flex-col justify-center text-center sm:max-w-lg lg:mx-0 lg:max-w-[min(100%,28rem)] lg:text-left">
                  <h1 className="hopekids-title-glare text-4xl font-extrabold drop-shadow-[0_4px_24px_rgba(0,0,0,0.75)] sm:text-5xl lg:text-6xl">
                    HopeKids
                  </h1>
                  <p className="mt-4 text-lg font-semibold leading-snug text-amber-50 drop-shadow-[0_2px_16px_rgba(0,0,0,0.85)] sm:mt-5 sm:text-xl lg:text-2xl">
                    Support sick children through cryptocurrency.
                  </p>
                  <p className="mx-auto mt-4 max-w-xl text-sm leading-relaxed text-stone-200/95 drop-shadow-[0_1px_12px_rgba(0,0,0,0.8)] sm:mt-5 sm:text-base lg:mx-0">
                    When you buy or trade HKIDS, part of every swap supports sick children.{' '}
                    <span className="font-semibold text-amber-200">3%</span> of each transaction goes to the public
                    donation wallet.
                  </p>
                  <div className="mt-7 flex flex-col items-center justify-center gap-3 sm:mt-8 sm:flex-row sm:flex-wrap lg:justify-start">
                    <a
                      href={JUPITER_BUY_URL}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex w-full min-w-[200px] items-center justify-center rounded-full border-2 border-blue-400/65 bg-transparent px-6 py-3.5 text-base font-bold tracking-tight text-blue-100 shadow-[0_0_24px_rgba(59,130,246,0.2)] backdrop-blur-sm transition-all duration-200 hover:scale-[1.02] hover:border-blue-300/90 hover:bg-blue-500/10 hover:text-white sm:w-auto"
                    >
                      Buy HopeKids
                    </a>
                    <a
                      href="#donations"
                      className="inline-flex w-full min-w-[200px] items-center justify-center rounded-full border border-amber-400/45 bg-amber-500/[0.08] px-6 py-3.5 text-base font-semibold text-amber-100/95 shadow-[0_0_28px_rgba(251,191,36,0.12)] backdrop-blur-sm transition hover:border-amber-300/60 hover:bg-amber-400/10 sm:w-auto"
                    >
                      View Donation Wallet
                    </a>
                  </div>
                </div>
              </section>
            </div>

            <section className="mt-6 grid gap-4 md:grid-cols-3">
              {stats.map((item) => (
                <div
                  key={item.label}
                  className="rounded-2xl border border-cyan-400/25 bg-[#071226]/28 px-4 py-4 shadow-[0_10px_25px_-5px_rgba(0,0,0,0.2),0_0_14px_rgba(56,189,248,0.12)] backdrop-blur transition-all duration-300 hover:-translate-y-1 hover:border-cyan-400/40 hover:shadow-[0_14px_32px_-8px_rgba(0,0,0,0.25),0_0_28px_rgba(56,189,248,0.2)] sm:px-6 sm:py-5"
                >
                  <div className="text-xs text-blue-100/72 sm:text-sm">{item.label}</div>
                  <div className="mt-2 flex items-end gap-2 sm:mt-3">
                    <span className="text-2xl font-extrabold tracking-tight sm:text-4xl">{item.value}</span>
                    {item.suffix ? <span className="pb-1 text-lg font-semibold text-blue-100/80">{item.suffix}</span> : null}
                  </div>
                </div>
              ))}
            </section>

            {/* removed: Where HopeKids Helps / Trade cards */}

            <section className="mt-8 scroll-mt-28" aria-label="Fundraising, donations, and supporting the project">
              <div className="grid grid-cols-1 gap-4 sm:gap-5 md:grid-cols-2 md:gap-6">
                <div className="flex h-full min-h-[200px] flex-col justify-center gap-4 rounded-2xl border border-cyan-400/25 bg-[#061126]/55 p-5 shadow-[0_0_14px_rgba(56,189,248,0.1)] backdrop-blur sm:min-h-[220px] sm:flex-row sm:items-center sm:gap-5 sm:p-6">
                  <div className="flex shrink-0 flex-col items-center sm:items-start">
                    <img
                      src={SPOTLIGHT_CHILD_IMAGE_SRC}
                      alt="Example HopeKids spotlight child (illustrative photo)"
                      width={144}
                      height={144}
                      className="h-28 w-28 rounded-xl object-cover shadow-[0_8px_24px_rgba(0,0,0,0.4)] ring-2 ring-cyan-400/35 sm:h-32 sm:w-32"
                      loading="lazy"
                      decoding="async"
                    />
                    <p className="mt-2 text-center text-sm font-semibold text-amber-100/95 sm:text-left">{SPOTLIGHT_CHILD_NAME}</p>
                  </div>
                  <div className="min-w-0 flex-1 text-center sm:text-left">
                    <div className="text-lg font-extrabold text-amber-200 sm:text-xl">Fundraiser</div>
                    <p className="mt-2 text-sm leading-relaxed text-blue-100/75 sm:text-base">
                      A HopeKids fundraiser for children who need care. Share the page, donate to the public wallet, or get
                      HKIDS — every contribution supports the mission.
                    </p>
                    <div
                      className="mt-4 rounded-xl border border-cyan-500/25 bg-black/25 px-3 py-2.5 sm:px-4"
                      role="timer"
                      aria-live="polite"
                      aria-label="Time remaining in this 30-day support window"
                    >
                      <p className="text-[10px] font-semibold uppercase tracking-wider text-cyan-200/80">Support window</p>
                      <p className="mt-1 font-mono text-lg tabular-nums text-cyan-100 sm:text-xl">
                        <span className="font-extrabold text-amber-200">{spotlightCountdown.hours}</span>
                        <span className="text-blue-100/60">h </span>
                        <span className="font-extrabold text-amber-200">{String(spotlightCountdown.minutes).padStart(2, '0')}</span>
                        <span className="text-blue-100/60">m </span>
                        <span className="font-extrabold text-amber-200">{String(spotlightCountdown.seconds).padStart(2, '0')}</span>
                        <span className="text-blue-100/60">s</span>
                      </p>
                      <p className="mt-0.5 text-[11px] text-blue-100/55">30-day cycle · hours shown first</p>
                    </div>
                  </div>
                </div>
                <div className="flex h-full min-h-[280px] flex-col justify-center rounded-2xl border border-cyan-400/25 bg-[#061126]/55 p-5 text-center shadow-[0_0_14px_rgba(56,189,248,0.1)] backdrop-blur sm:min-h-0 sm:p-6 sm:text-left">
                  <div className="text-lg font-extrabold text-amber-200 sm:text-xl">Help children</div>
                  <p className="mt-2 text-sm leading-relaxed text-blue-100/75 sm:text-base">
                    <span className="font-semibold text-amber-200/95">3%</span> of each transaction goes to the public
                    donation wallet for sick children.
                  </p>
                  <div className="mt-5 border-t border-cyan-400/20 pt-4">
                    <p className="text-[11px] font-bold uppercase tracking-[0.12em] text-cyan-200/90">Support the project</p>
                    <ul className="mx-auto mt-3 max-w-md space-y-2.5 text-left text-sm leading-snug text-blue-100/82 sm:mx-0">
                      <li className="flex gap-2.5">
                        <span
                          className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-gradient-to-br from-amber-400 to-cyan-400 shadow-[0_0_8px_rgba(56,189,248,0.5)]"
                          aria-hidden="true"
                        />
                        <span>
                          <span className="font-semibold text-blue-100/95">Growth ideas</span> — new campaigns, better
                          storytelling, or features that make donating and tracking impact easier.
                        </span>
                      </li>
                      <li className="flex gap-2.5">
                        <span
                          className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-gradient-to-br from-amber-400 to-cyan-400 shadow-[0_0_8px_rgba(56,189,248,0.5)]"
                          aria-hidden="true"
                        />
                        <span>
                          <span className="font-semibold text-blue-100/95">Partnerships</span> — brands, creators, hospitals,
                          or NGOs that share the mission and want to co-create reach or events.
                        </span>
                      </li>
                      <li className="flex gap-2.5">
                        <span
                          className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-gradient-to-br from-amber-400 to-cyan-400 shadow-[0_0_8px_rgba(56,189,248,0.5)]"
                          aria-hidden="true"
                        />
                        <span>
                          <span className="font-semibold text-blue-100/95">Build &amp; ship</span> — developers, designers,
                          or volunteers who can help improve the site, wallet flows, or transparency tools.
                        </span>
                      </li>
                      <li className="flex gap-2.5">
                        <span
                          className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-gradient-to-br from-amber-400 to-cyan-400 shadow-[0_0_8px_rgba(56,189,248,0.5)]"
                          aria-hidden="true"
                        />
                        <span>
                          <span className="font-semibold text-blue-100/95">Spread the word</span> — share on socials, invite
                          communities, and point people to the public donation wallet and HKIDS.
                        </span>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </section>

            <section id="tokenomics" className="mt-10 scroll-mt-28" aria-labelledby="tok-heading">
              <h2 id="tok-heading" className="sr-only">
                Tokenomics and roadmap
              </h2>
              <div className="grid gap-6 lg:grid-cols-2">
                <div className="rounded-2xl border border-cyan-400/25 bg-[#061126]/35 p-5 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur sm:p-6">
                  <div className="text-xl font-extrabold text-white">Tokenomics</div>
                  <p className="mt-3 text-sm text-blue-100/75">Total supply</p>
                  <p className="text-xl font-extrabold tabular-nums text-cyan-100 sm:text-2xl">1,000,000,000,000 HKIDS</p>
                  <div className="mt-6 grid grid-cols-3 gap-2">
                    <div className="rounded-xl border border-amber-400/30 bg-black/25 px-1 py-3 text-center sm:px-2">
                      <div className="text-lg font-extrabold text-amber-300">3%</div>
                      <div className="text-[10px] font-medium leading-tight text-blue-100/70">Children wallet</div>
                    </div>
                    <div className="rounded-xl border border-cyan-400/30 bg-black/25 px-1 py-3 text-center sm:px-2">
                      <div className="text-lg font-extrabold text-cyan-200">2%</div>
                      <div className="text-[10px] font-medium leading-tight text-blue-100/70">Marketing</div>
                    </div>
                    <div className="rounded-xl border border-violet-400/30 bg-black/25 px-1 py-3 text-center sm:px-2">
                      <div className="text-lg font-extrabold text-violet-200">1%</div>
                      <div className="text-[10px] font-medium leading-tight text-blue-100/70">Development</div>
                    </div>
                  </div>
                  <div className="mt-4 rounded-xl border border-white/10 bg-black/20 p-3 text-sm text-blue-100/85">
                    <span className="text-blue-100/55">Live market cap: </span>
                    {tokenStats.loading
                      ? '…'
                      : tokenStats.marketCapUsd != null
                        ? formatUsdCompact(tokenStats.marketCapUsd)
                        : FALLBACK_MARKET_CAP}
                    {tokenStats.priceUsd ? (
                      <span className="mt-1 block text-xs text-blue-100/60">Price: {tokenStats.priceUsd}</span>
                    ) : null}
                    <a
                      href={tokenStats.dexscreenerUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="mt-2 inline-block text-xs font-semibold text-cyan-300/90 underline hover:text-cyan-200"
                    >
                      DexScreener ↗
                    </a>
                  </div>
                  <a
                    href={SOLSCAN_TOKEN_URL}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="mt-4 inline-flex rounded-xl border border-cyan-400/40 bg-blue-600/90 px-4 py-2.5 text-sm font-bold text-white shadow-[0_0_20px_rgba(37,99,235,0.35)] transition hover:bg-blue-500"
                  >
                    View on Solscan
                  </a>
                </div>
                <div className="rounded-2xl border border-cyan-400/25 bg-[#061126]/35 p-5 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur sm:p-6">
                  <div className="text-xl font-extrabold text-white">Roadmap</div>
                  <ul className="relative mt-6 space-y-6 border-l border-cyan-500/35 pl-6">
                    <li className="relative">
                      <span className="absolute -left-[29px] top-1.5 h-3 w-3 rounded-full bg-gradient-to-br from-amber-400 to-cyan-400 shadow-[0_0_10px_rgba(56,189,248,0.75)]" />
                      <div className="font-bold text-amber-200/95">Wallet address</div>
                      <p className="break-all font-mono text-xs text-blue-100/70 sm:text-sm">{PUBLIC_DONATION_WALLET}</p>
                    </li>
                    <li className="relative">
                      <span className="absolute -left-[29px] top-1.5 h-3 w-3 rounded-full bg-gradient-to-br from-amber-400 to-cyan-400 shadow-[0_0_10px_rgba(56,189,248,0.75)]" />
                      <div className="font-bold text-amber-200/95">2026</div>
                      <p className="text-sm text-blue-100/72">Website + donation system</p>
                    </li>
                    <li className="relative">
                      <span className="absolute -left-[29px] top-1.5 h-3 w-3 rounded-full bg-gradient-to-br from-amber-400 to-cyan-400 shadow-[0_0_10px_rgba(56,189,248,0.75)]" />
                      <div className="font-bold text-amber-200/95">2026</div>
                      <p className="text-sm text-blue-100/72">Community growth</p>
                    </li>
                    <li className="relative">
                      <span className="absolute -left-[29px] top-1.5 h-3 w-3 rounded-full bg-gradient-to-br from-amber-400 to-cyan-400 shadow-[0_0_10px_rgba(56,189,248,0.75)]" />
                      <div className="font-bold text-amber-200/95">2027</div>
                      <p className="text-sm text-blue-100/72">Global charity partnerships</p>
                    </li>
                  </ul>
                </div>
              </div>
            </section>

            <section id="mission" className="mt-8 scroll-mt-28">
              <button
                type="button"
                onClick={() => setStoryOpen(true)}
                className="w-full rounded-2xl border border-cyan-400/25 bg-[#061126]/28 p-5 text-left shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur transition-all duration-200 hover:border-cyan-400/45 hover:bg-[#071a35]/40 hover:shadow-[0_0_22px_rgba(56,189,248,0.18)] active:scale-[0.99] sm:p-6"
              >
                <div className="text-2xl sm:text-3xl" aria-hidden="true">
                  ✨
                </div>
                <div className="mt-2 text-2xl font-extrabold sm:text-3xl">Mission — What is HopeKids?</div>
                <p className="mt-2 text-sm text-blue-100/74 sm:text-base">
                  A movement of hope — tap to read our full story.
                </p>
                <p className="mt-3 text-[11px] font-semibold uppercase tracking-wide text-cyan-300/70">Open</p>
              </button>
            </section>

            <section className="mt-6 sm:mt-8" id="donations">
              <div className="rounded-2xl border border-cyan-400/25 bg-[#061126]/28 p-4 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur sm:rounded-[26px] sm:p-6">
                <div className="text-2xl font-extrabold sm:text-[34px]">Transparency</div>
                <div className="mt-4 rounded-2xl border border-cyan-400/20 bg-[#08172f]/50 p-4 shadow-[0_0_12px_rgba(56,189,248,0.1)] sm:mt-5 sm:p-5">
                  <div className="text-lg font-bold sm:text-xl">Public Donation Wallet</div>
                  <div className="mt-3 flex min-w-0 items-stretch gap-2 rounded-xl border border-white/10 bg-black/20 sm:mt-4 sm:gap-3">
                    <div className="min-w-0 flex-1 px-3 py-2.5 font-mono text-sm leading-relaxed text-blue-100/90 break-all sm:px-4 sm:py-3 sm:text-base">
                      {PUBLIC_DONATION_WALLET}
                    </div>
                    <button
                      type="button"
                      onClick={copyDonationWallet}
                      aria-label={walletCopied ? 'Copied' : 'Copy wallet address'}
                      className="flex shrink-0 items-center justify-center border-l border-white/10 px-3 text-cyan-300 transition hover:bg-white/5 hover:text-cyan-200 active:scale-[0.97] sm:px-4"
                    >
                      {walletCopied ? (
                        <svg viewBox="0 0 24 24" className="h-6 w-6" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
                          <path d="M20 6L9 17l-5-5" strokeLinecap="round" strokeLinejoin="round" />
                        </svg>
                      ) : (
                        <svg viewBox="0 0 24 24" className="h-6 w-6" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
                          <rect x="9" y="9" width="13" height="13" rx="2" />
                          <path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1" />
                        </svg>
                      )}
                    </button>
                  </div>
                  {walletCopied ? (
                    <p className="mt-2 text-sm font-medium text-emerald-300/90" role="status">
                      Copied to clipboard
                    </p>
                  ) : null}
                </div>
              </div>
            </section>

            <section id="community" className="mt-8 scroll-mt-28 sm:mt-10" aria-labelledby="community-heading">
              <h2 id="community-heading" className="text-center text-2xl font-extrabold text-white sm:text-3xl">
                Community
              </h2>
              <p className="mx-auto mt-2 max-w-lg text-center text-sm text-blue-100/75">
                Follow on Twitter, Instagram, and TikTok — live charts on DexScreener.
              </p>
              <div className="mt-6 grid grid-cols-2 gap-2 sm:grid-cols-4 sm:gap-3">
                <a
                  href={SOCIAL_TWITTER_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-xl border border-cyan-400/25 bg-[#061126]/40 px-2 py-3 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.1)] backdrop-blur transition-all duration-200 hover:scale-[1.02] hover:border-cyan-400/45 hover:bg-[#071a35]/45"
                  aria-label="Twitter"
                >
                  <span className="flex h-8 w-8 items-center justify-center rounded-full bg-white/8 shadow-[0_0_12px_rgba(148,163,184,0.2)]">
                    <IconTwitterX className="h-4 w-4 text-slate-100" />
                  </span>
                  <span className="text-[11px] font-semibold">Twitter</span>
                </a>
                <a
                  href={SOCIAL_INSTAGRAM_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-xl border border-cyan-400/25 bg-[#061126]/40 px-2 py-3 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.1)] backdrop-blur transition-all duration-200 hover:scale-[1.02] hover:border-cyan-400/45 hover:bg-[#071a35]/45"
                  aria-label="Instagram"
                >
                  <span className="flex h-8 w-8 items-center justify-center rounded-full bg-pink-500/20 shadow-[0_0_12px_rgba(236,72,153,0.25)]">
                    <IconInstagram className="h-4 w-4 text-pink-200" />
                  </span>
                  <span className="text-[11px] font-semibold">Instagram</span>
                </a>
                <a
                  href={SOCIAL_TIKTOK_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-xl border border-cyan-400/25 bg-[#061126]/40 px-2 py-3 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.1)] backdrop-blur transition-all duration-200 hover:scale-[1.02] hover:border-cyan-400/45 hover:bg-[#071a35]/45"
                  aria-label="TikTok"
                >
                  <span className="flex h-8 w-8 items-center justify-center rounded-full bg-cyan-500/15 shadow-[0_0_12px_rgba(6,182,212,0.3)]">
                    <IconTikTok className="h-4 w-4 text-cyan-200" />
                  </span>
                  <span className="text-[11px] font-semibold">TikTok</span>
                </a>
                <a
                  href={tokenStats.dexscreenerUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-xl border border-cyan-400/25 bg-[#061126]/40 px-2 py-3 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.1)] backdrop-blur transition-all duration-200 hover:scale-[1.02] hover:border-cyan-400/45 hover:bg-[#071a35]/45"
                  aria-label="DexScreener"
                >
                  <span className="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500/15 shadow-[0_0_12px_rgba(52,211,153,0.25)]">
                    <IconDexScreener className="h-4 w-4" />
                  </span>
                  <span className="text-[11px] font-semibold">DexScreener</span>
                </a>
              </div>
            </section>

            <section className="mt-6 sm:mt-8" id="contact" aria-labelledby="contact-heading">
              <div className="rounded-2xl border border-cyan-400/25 bg-[#061126]/28 p-4 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur sm:rounded-[26px] sm:p-6">
                <h2 id="contact-heading" className="text-2xl font-extrabold sm:text-[34px]">
                  Contact the team
                </h2>
                <p className="mt-2 max-w-2xl text-sm text-blue-100/75 sm:text-base">
                  Questions, partnerships, or support — email us. We respond to HopeKids-related messages.
                </p>
                <div className="mt-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:gap-4">
                  <a
                    href={`mailto:${HOPEKIDS_TEAM_EMAIL}`}
                    className="inline-flex w-fit items-center gap-2 rounded-xl border border-cyan-400/30 bg-[#08172f]/60 px-4 py-3 text-base font-semibold text-cyan-200 transition hover:border-cyan-400/50 hover:bg-[#0a1f42]/80"
                  >
                    <svg viewBox="0 0 24 24" className="h-5 w-5 shrink-0" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
                      <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                      <path d="m22 6-10 7L2 6" />
                    </svg>
                    {HOPEKIDS_TEAM_EMAIL}
                  </a>
                </div>
              </div>
            </section>

            <footer className="border-t-4 border-orange-500 bg-black/20 py-8 text-center text-blue-100/70 sm:py-10">
              <div className="flex flex-col items-center gap-3">
                <span className="rounded-[13px] opacity-95 shadow-[0_4px_20px_rgba(0,0,0,0.35)] ring-1 ring-white/10">
                  <HopeKidsBrandMark className="h-10 w-10 sm:h-11 sm:w-11" />
                </span>
                <div className="text-2xl font-extrabold text-white sm:text-3xl">HopeKids © 2026</div>
                <div className="text-base sm:text-lg">Trade crypto. Give hope.</div>
              </div>
            </footer>
          </div>
        </div>
      </div>

      {storyOpen ? (
        <div
          className="fixed inset-0 z-[100] flex items-start justify-center overflow-y-auto py-6 sm:py-10"
          role="dialog"
          aria-modal="true"
          aria-labelledby="hopekids-story-title"
        >
          <button
            type="button"
            aria-label="Close story"
            className="fixed inset-0 bg-black/75 backdrop-blur-sm"
            onClick={() => setStoryOpen(false)}
          />
          <div className="relative z-[1] mx-4 w-full max-w-2xl overflow-hidden rounded-2xl border border-cyan-400/35 shadow-[0_0_40px_rgba(56,189,248,0.15)]">
            <div
              className="pointer-events-none absolute inset-0 bg-[url('https://images.unsplash.com/photo-1446776653964-20c1d3a81b06')] bg-cover bg-center"
              aria-hidden="true"
            />
            <div
              className="pointer-events-none absolute inset-0 bg-[linear-gradient(180deg,rgba(2,11,31,0.28),rgba(7,26,58,0.4))]"
              aria-hidden="true"
            />
            <div
              className="pointer-events-none absolute inset-x-0 top-0 h-[280px] bg-[radial-gradient(circle_at_72%_28%,rgba(251,146,60,0.22),transparent_22%),radial-gradient(circle_at_60%_18%,rgba(59,130,246,0.22),transparent_26%)]"
              aria-hidden="true"
            />
            <div className="relative z-[1] bg-[linear-gradient(180deg,rgba(4,10,25,0.72),rgba(3,7,18,0.88))] p-5 sm:p-8">
              <div className="flex items-start justify-between gap-4 border-b border-amber-400/25 pb-4">
                <h2 id="hopekids-story-title" className="text-xl font-extrabold text-amber-300 sm:text-2xl">
                  The HopeKids story
                </h2>
                <button
                  type="button"
                  onClick={() => setStoryOpen(false)}
                  className="shrink-0 rounded-lg border border-amber-400/35 px-3 py-1.5 text-sm font-semibold text-amber-200 transition hover:bg-amber-400/10 hover:text-amber-100"
                >
                  Close
                </button>
              </div>
              <div className="max-h-[min(70vh,540px)] overflow-y-auto pr-1 pt-5 sm:max-h-[min(75vh,620px)]">
                <div className="space-y-4 text-sm leading-relaxed text-amber-100/95 sm:text-base">
                  <p>
                    Today, all it takes is opening social media to see something that breaks your heart. Post after post.
                    Photo after photo. Small children who, instead of playing, laughing, and discovering the world… are
                    fighting for their lives. Pleas for help with treatment, fundraisers, heartbreaking stories of parents
                    who are doing everything they can — and still often feel helpless.
                  </p>
                  <p>You can&apos;t just scroll past this without feeling anything.</p>
                  <p>
                    HopeKids was born from that feeling — from pain, sadness, and at the same time, from deep hope. From
                    the question: <em>why them?</em> Why do these innocent children, who have only just begun their lives,
                    have to face something so cruel?
                  </p>
                  <p>This is a project created from the heart.</p>
                  <p>
                    HopeKids is not another token built for quick profit, hype, or millions. It&apos;s something completely
                    different. It&apos;s a symbol. It&apos;s a voice for those who cannot fight for themselves. It&apos;s an
                    attempt to do something… instead of just watching and scrolling past.
                  </p>
                  <p>Because the truth is — these children do not deserve what has happened to them.</p>
                  <p>
                    Each of us has a choice — we can walk past, or we can stop for a moment and help. Even the smallest
                    gesture matters. For us, it may be very little… but for them, it could be a chance to live.
                  </p>
                  <p>
                    HopeKids was created with the belief that together, we can change something. That even in a world full
                    of suffering, there is still room for goodness. For people who are not indifferent.
                  </p>
                  <p>
                    Because somewhere out there is a child falling asleep in pain today… And a parent quietly crying,
                    praying that tomorrow will still come.
                  </p>
                  <p>
                    And the worst part is… while you&apos;re reading this — someone is losing that fight.
                  </p>
                  <p>A heart stops beating.</p>
                  <p>A child&apos;s world fades away.</p>
                  <p>And with it… the entire universe of their parents.</p>
                  <p>Let&apos;s not allow the only thing left behind to be a photo and a fundraising link.</p>
                  <p>Stop for a moment.</p>
                  <p>
                    I know you scroll through hundreds of posts every day… but one of them could change someone&apos;s life
                    today.
                  </p>
                  <p>You don&apos;t have to do everything. It&apos;s enough to do something.</p>
                  <p>Click &ldquo;like.&rdquo;</p>
                  <p>Share it.</p>
                  <p>Show that you see them.</p>
                  <p>Because for you, it&apos;s just a second. For them… it could be hope.</p>
                  <p>Don&apos;t scroll past.</p>
                  <p>Don&apos;t forget.</p>
                  <p>Don&apos;t be indifferent.</p>
                  <p>Because hope dies when people stop acting.</p>
                  <p>And if you&apos;re still here…</p>
                  <p>it means you can be the reason someone&apos;s story doesn&apos;t end today.</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      ) : null}
    </>
  );
}
