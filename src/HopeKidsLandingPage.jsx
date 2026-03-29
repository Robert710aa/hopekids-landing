import { useCallback, useEffect, useState } from 'react';

/** Full story — shown in the “What is HopeKids?” modal */
const HOPEKIDS_STORY_PARAGRAPHS_PL = [
  'HopEKids is not just a project – it is a movement born from love and hope, created to support the smallest and most innocent among us. Every child who becomes part of HopEKids is like a ray of hope – small, yet incredibly valuable.',
  'It is a call not only to donors, but also to parents who want to pass compassion and empathy on to their children. Together, over 30 days, we build a bridge through social media – on platforms like Facebook, TikTok, and Twitter – where every story becomes a call for help.',
  'First, we search for children who need help the most and the fastest – those whose situations are the most difficult and urgent. Then we choose one child whose story has touched us the most, contact their family, and provide a dedicated wallet – a symbol of one-time, personal support.',
  'Additionally, HopEKids tokens are not just about support – they are a tool that helps build financial stability. They create a bridge between everyday support and the future, where every investment leads to real change.',
  'This is not only an appeal to our hearts, but also to a vision of a better tomorrow – where each of us, together, can change the world of these children. HopEKids is a bridge that connects our community with the future – and it is up to us to ensure that every small life has the chance to shine to its fullest potential.',
];

// HKIDS token mint on Solana (Jupiter swap)
const HKIDS_MINT = '6u5PLy9ePpuGEBK3kmQ9isVDFjqSurKpvmCFzheDgQke';
const JUPITER_BUY_URL = `https://jup.ag/swap/SOL-${HKIDS_MINT}`;
const DEXSCREENER_TOKEN_URL = `https://api.dexscreener.com/latest/dex/tokens/${HKIDS_MINT}`;
/** DexScreener token page shows holders; public API JSON does not include holder count. */
const DEXSCREENER_TOKEN_PAGE = `https://dexscreener.com/solana/${HKIDS_MINT}`;

/** Public donation wallet (Solana) */
const PUBLIC_DONATION_WALLET = 'GnhmPt4LBHRoABuGrSqrbPW34Mu8dXGJf1XCNc7DHRAB';

/** HopeKids team inbox */
const HOPEKIDS_TEAM_EMAIL = 'hopekids594@gmail.com';

const FALLBACK_MARKET_CAP = '$3,250,000';

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
    { label: 'Tokens Saved for Children', value: '3,245,678', suffix: 'HKIDS' },
    { label: 'Current Value', value: '$16,380', suffix: '' },
    { label: 'Total Transactions Helping Children', value: '15,284', suffix: '' },
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
      `}</style>

      <div className="min-h-screen text-white bg-[url('https://images.unsplash.com/photo-1446776653964-20c1d3a81b06')] bg-cover bg-center bg-fixed">
        <div className="relative overflow-hidden min-h-screen">
          <div className="absolute inset-0 bg-[linear-gradient(180deg,rgba(2,11,31,0.05),rgba(7,26,58,0.08))]" />
          <div className="absolute inset-x-0 top-0 h-[420px] bg-[radial-gradient(circle_at_72%_28%,rgba(251,146,60,0.35),transparent_20%),radial-gradient(circle_at_60%_18%,rgba(59,130,246,0.35),transparent_24%)]" />

          <div className="relative z-10 mx-auto max-w-[1180px] px-4 py-4 sm:px-6 lg:px-8">
            <section className="relative overflow-hidden rounded-2xl sm:rounded-[28px] border border-cyan-400/25 bg-[linear-gradient(180deg,rgba(4,10,25,0.25),rgba(3,7,18,0.38))] shadow-[0_25px_50px_-12px_rgba(0,0,0,0.3),0_0_20px_rgba(56,189,248,0.1)] px-4 py-10 sm:px-6 sm:py-14 lg:px-12 lg:py-20">
              <div className="absolute bottom-0 left-0 right-0 h-32 bg-[linear-gradient(180deg,transparent,rgba(0,0,0,0.35))]" />
              <div className="absolute right-24 top-10 h-[320px] w-[320px] rounded-full bg-[radial-gradient(circle,rgba(59,130,246,0.45),transparent_60%)] blur-2xl animate-pulse" />

              <div className="relative z-10 grid items-center gap-6 sm:gap-8 lg:grid-cols-2 lg:gap-10">
                <div className="text-center lg:text-left">
                  <h1 className="text-4xl font-extrabold text-amber-400 sm:text-5xl">HopeKids</h1>

                  <p className="mt-4 text-lg font-semibold text-blue-100 sm:mt-6 sm:text-2xl">
                    Trade Crypto. Give Hope.<br />Help Children.
                  </p>

                  <p className="mt-4 max-w-xl text-blue-200 sm:mt-6 sm:text-base">
                    Each transaction saves tokens to help children.
                    <br />
                    5% of every transaction goes to the public donation wallet.
                  </p>

                  <div className="mt-6 flex flex-col gap-3 sm:mt-8 sm:flex-row sm:gap-4 sm:justify-center lg:justify-start">
                    <a
                      href={JUPITER_BUY_URL}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex justify-center rounded-xl bg-blue-600 px-5 py-3 font-bold transition-all duration-200 hover:scale-[1.03] hover:bg-blue-500 active:scale-[0.98] sm:px-6"
                    >
                      Buy Token
                    </a>

                    <button className="rounded-xl border border-white/30 px-5 py-3 font-bold transition-all duration-200 hover:scale-[1.03] hover:bg-white/10 active:scale-[0.98] sm:px-6">
                      View Donation Wallet
                    </button>
                  </div>
                </div>

                <div className="flex justify-center lg:justify-end animate-[float_6s_ease-in-out_infinite]">
                  <div className="relative flex h-[220px] w-[220px] items-center justify-center sm:h-[280px] sm:w-[280px] lg:h-[360px] lg:w-[360px]">
                    <div className="absolute inset-0 rounded-full bg-[radial-gradient(circle,rgba(255,166,0,0.32),transparent_62%)] blur-3xl" />
                    <div className="absolute right-2 top-2 h-[180px] w-[180px] rounded-full bg-[radial-gradient(circle,rgba(56,189,248,0.28),transparent_65%)] blur-2xl sm:right-4 sm:top-4 sm:h-[240px] sm:w-[240px] lg:right-6 lg:top-4 lg:h-[300px] lg:w-[300px]" />
                    <div className="relative z-10 h-[180px] w-[180px] overflow-hidden rounded-full bg-transparent sm:h-[220px] sm:w-[220px] lg:h-[260px] lg:w-[260px]">
                      <div className="pointer-events-none absolute inset-[-18px] rounded-full bg-[radial-gradient(circle,rgba(255,190,80,0.35),transparent_62%)] blur-2xl" />
                      <img
                        src="/hopekids-coin.png"
                        alt="HopeKids Coin"
                        className="relative z-10 h-full w-full object-cover scale-[1.18] drop-shadow-[0_0_40px_rgba(255,190,80,0.55)]"
                      />
                      <div className="pointer-events-none absolute left-1/2 top-[-25%] h-[160%] w-[18%] -translate-x-1/2 bg-[linear-gradient(90deg,transparent,rgba(255,255,255,0.5),transparent)] blur-md [animation:shineSweep_6s_ease-in-out_infinite]" />
                    </div>
                  </div>
                </div>
              </div>

              {/* Social icons — full width under hero */}
              <div className="relative z-10 mt-8 grid w-full grid-cols-2 gap-2 sm:mt-10 sm:grid-cols-4 sm:gap-3">
                <a
                  href="#"
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-lg border border-cyan-400/25 bg-[#061126]/28 px-1.5 py-2 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur transition-all duration-200 hover:scale-[1.02] hover:border-cyan-400/40 hover:bg-[#071a35]/35 hover:shadow-[0_0_18px_rgba(56,189,248,0.18)] active:scale-[0.98]"
                  aria-label="TikTok"
                >
                  <span className="flex h-6 w-6 items-center justify-center rounded-full bg-white/5 shadow-[0_0_12px_rgba(56,189,248,0.18)]">
                    <svg viewBox="0 0 24 24" className="h-3.5 w-3.5 text-cyan-300" fill="currentColor" aria-hidden="true">
                      <path d="M19.59 6.69a4.83 4.83 0 0 1-3.77-4.25V2h-3.45v13.67a2.89 2.89 0 0 1-5.2 1.74 2.89 2.89 0 0 1 2.31-4.64 2.93 2.93 0 0 1 .88.13V9.4a6.84 6.84 0 0 0-1-.05A6.33 6.33 0 0 0 5 20.1a6.34 6.34 0 0 0 10.86-4.43v-7a8.16 8.16 0 0 0 4.77 1.52v-3.4a4.85 4.85 0 0 1-1-.1z" />
                    </svg>
                  </span>
                  <span className="text-[10px] font-semibold leading-none">TikTok</span>
                </a>

                <a
                  href="#"
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-lg border border-cyan-400/25 bg-[#061126]/28 px-1.5 py-2 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur transition-all duration-200 hover:scale-[1.02] hover:border-cyan-400/40 hover:bg-[#071a35]/35 hover:shadow-[0_0_18px_rgba(56,189,248,0.18)] active:scale-[0.98]"
                  aria-label="Twitter / X"
                >
                  <span className="flex h-6 w-6 items-center justify-center rounded-full bg-white/5 shadow-[0_0_12px_rgba(148,163,184,0.16)]">
                    <svg viewBox="0 0 24 24" className="h-3.5 w-3.5 text-slate-200" fill="currentColor" aria-hidden="true">
                      <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                    </svg>
                  </span>
                  <span className="text-[10px] font-semibold leading-none">Twitter</span>
                </a>

                <a
                  href="#"
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-lg border border-cyan-400/25 bg-[#061126]/28 px-1.5 py-2 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur transition-all duration-200 hover:scale-[1.02] hover:border-cyan-400/40 hover:bg-[#071a35]/35 hover:shadow-[0_0_18px_rgba(56,189,248,0.18)] active:scale-[0.98]"
                  aria-label="DexScreener"
                >
                  <span className="flex h-6 w-6 items-center justify-center rounded-full bg-white/5 shadow-[0_0_12px_rgba(34,211,238,0.14)]">
                    <svg viewBox="0 0 24 24" className="h-3.5 w-3.5 text-emerald-200" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
                      <path d="M4 16l5-5 4 4 7-7" />
                      <path d="M20 7v6h-6" />
                    </svg>
                  </span>
                  <span className="text-[10px] font-semibold leading-none">DexScreener</span>
                </a>

                <a
                  href="#"
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-lg border border-cyan-400/25 bg-[#061126]/28 px-1.5 py-2 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur transition-all duration-200 hover:scale-[1.02] hover:border-cyan-400/40 hover:bg-[#071a35]/35 hover:shadow-[0_0_18px_rgba(56,189,248,0.18)] active:scale-[0.98]"
                  aria-label="Facebook"
                >
                  <span className="flex h-6 w-6 items-center justify-center rounded-full bg-white/5 shadow-[0_0_12px_rgba(59,130,246,0.18)]">
                    <svg viewBox="0 0 24 24" className="h-3.5 w-3.5 text-blue-300" fill="currentColor" aria-hidden="true">
                      <path d="M12 2C6.477 2 2 6.477 2 12c0 5.013 3.693 9.153 8.505 9.876V14.89H8.89v-2.89h2.615V9.846c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.986C18.307 21.153 22 17.013 22 12c0-5.523-4.477-10-10-10z" />
                    </svg>
                  </span>
                  <span className="text-[10px] font-semibold leading-none">Facebook</span>
                </a>
              </div>
            </section>

            <section className="mt-6 grid gap-4 md:grid-cols-3">
              {stats.map((item) => (
                <div key={item.label} className="rounded-2xl border border-cyan-400/25 bg-[#071226]/28 px-4 py-4 shadow-[0_10px_25px_-5px_rgba(0,0,0,0.2),0_0_14px_rgba(56,189,248,0.12)] backdrop-blur sm:px-6 sm:py-5">
                  <div className="text-xs text-blue-100/72 sm:text-sm">{item.label}</div>
                  <div className="mt-2 flex items-end gap-2 sm:mt-3">
                    <span className="text-2xl font-extrabold tracking-tight sm:text-4xl">{item.value}</span>
                    {item.suffix ? <span className="pb-1 text-lg font-semibold text-blue-100/80">{item.suffix}</span> : null}
                  </div>
                </div>
              ))}
            </section>

            {/* removed: Where HopeKids Helps / Trade cards */}

            <section className="mt-6 grid grid-cols-1 gap-4 sm:mt-8 sm:grid-cols-2 lg:grid-cols-3">
              <button
                type="button"
                onClick={() => setStoryOpen(true)}
                className="rounded-2xl border border-cyan-400/25 bg-[#061126]/28 p-4 text-left shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur transition-all duration-200 hover:border-cyan-400/45 hover:bg-[#071a35]/40 hover:shadow-[0_0_22px_rgba(56,189,248,0.18)] active:scale-[0.99] sm:p-5"
              >
                <div className="text-2xl sm:text-3xl" aria-hidden="true">
                  ✨
                </div>
                <div className="mt-2 text-2xl font-extrabold sm:mt-3 sm:text-[32px]">What is HopeKids?</div>
                <p className="mt-1 text-sm text-blue-100/74 sm:mt-2 sm:text-base">
                  A movement of hope — tap to read our full story.
                </p>
                <p className="mt-2 text-[11px] font-semibold uppercase tracking-wide text-cyan-300/70">Open</p>
              </button>
              <div className="rounded-2xl border border-cyan-400/25 bg-[#061126]/28 p-4 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur sm:p-5">
                <div className="text-2xl sm:text-3xl">💛</div>
                <div className="mt-2 text-2xl font-extrabold sm:mt-3 sm:text-[32px]">Help</div>
                <p className="mt-1 text-sm text-blue-100/74 sm:mt-2 sm:text-base">Help children every transaction.</p>
              </div>
              {/* removed: Impact card */}
              <div className="rounded-2xl border border-cyan-400/25 bg-[#061126]/28 p-4 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur sm:p-5 sm:col-span-2 lg:col-span-1">
                <div className="text-xs text-blue-100/72 sm:text-sm">Market Cap</div>
                <div className="mt-2 text-3xl font-extrabold tabular-nums sm:mt-3 sm:text-4xl">
                  {tokenStats.loading
                    ? '…'
                    : tokenStats.marketCapUsd != null
                      ? formatUsdCompact(tokenStats.marketCapUsd)
                      : FALLBACK_MARKET_CAP}
                </div>
                <div className="mt-2 space-y-0.5 text-sm text-blue-100/74 sm:mt-3">
                  {tokenStats.priceUsd ? (
                    <div>
                      Price: <span className="font-semibold text-blue-100/90">{tokenStats.priceUsd}</span>
                    </div>
                  ) : null}
                  {tokenStats.liquidityUsd ? (
                    <div>
                      DEX liquidity:{' '}
                      <span className="font-semibold text-blue-100/90">{tokenStats.liquidityUsd}</span>
                    </div>
                  ) : null}
                  <div className="mt-2 pt-0.5">
                    <a
                      href={tokenStats.dexscreenerUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-[12px] font-semibold text-cyan-300/90 underline decoration-cyan-400/35 underline-offset-2 hover:text-cyan-200"
                    >
                      Holders on DexScreener ↗
                    </a>
                  </div>
                  {!tokenStats.loading && (tokenStats.priceUsd || tokenStats.liquidityUsd) ? (
                    <div className="text-[11px] text-blue-100/55">
                      Market data: DexScreener API · refreshes about every 90s
                    </div>
                  ) : null}
                  {!tokenStats.loading && !tokenStats.priceUsd && !tokenStats.liquidityUsd ? (
                    <div className="text-blue-100/60">No DEX pair — fallback market cap shown above</div>
                  ) : null}
                </div>
              </div>
            </section>

            <section className="mt-6 sm:mt-8">
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

            <footer className="py-8 text-center text-blue-100/70 sm:py-10">
              <div className="text-2xl font-extrabold text-white sm:text-3xl">HopeKids © 2026</div>
              <div className="mt-1 text-base sm:mt-2 sm:text-lg">Trade crypto. Give hope.</div>
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
              className="pointer-events-none absolute inset-0 bg-[linear-gradient(180deg,rgba(2,11,31,0.05),rgba(7,26,58,0.08))]"
              aria-hidden="true"
            />
            <div
              className="pointer-events-none absolute inset-x-0 top-0 h-[280px] bg-[radial-gradient(circle_at_72%_28%,rgba(251,146,60,0.35),transparent_20%),radial-gradient(circle_at_60%_18%,rgba(59,130,246,0.35),transparent_24%)]"
              aria-hidden="true"
            />
            <div className="relative z-[1] bg-[linear-gradient(180deg,rgba(4,10,25,0.25),rgba(3,7,18,0.38))] p-5 sm:p-8">
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
                  {HOPEKIDS_STORY_PARAGRAPHS_PL.map((p, i) => (
                    <p key={i}>{p}</p>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      ) : null}
    </>
  );
}
