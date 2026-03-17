// Adres mint tokena HKIDS na Solana – do swapu na Jupiter
const HKIDS_MINT = '6u5PLy9ePpuGEBK3kmQ9isVDFjqSurKpvmCFzheDgQke';
const JUPITER_BUY_URL = `https://jup.ag/swap/SOL-${HKIDS_MINT}`;

export default function HopeKidsLandingPage() {
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

              {/* Ikony społecznościowe na całą szerokość hero */}
              <div className="relative z-10 mt-8 grid w-full grid-cols-2 gap-2 sm:mt-10 sm:grid-cols-4 sm:gap-3">
                <a
                  href="#"
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-lg border border-cyan-400/25 bg-[#061126]/28 px-1.5 py-2 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur transition-all duration-200 hover:scale-[1.02] hover:border-cyan-400/40 hover:bg-[#071a35]/35 hover:shadow-[0_0_18px_rgba(56,189,248,0.18)] active:scale-[0.98]"
                  aria-label="Telegram"
                >
                  <span className="flex h-6 w-6 items-center justify-center rounded-full bg-white/5 shadow-[0_0_12px_rgba(56,189,248,0.18)]">
                    <svg viewBox="0 0 24 24" className="h-3.5 w-3.5 text-cyan-300" fill="currentColor" aria-hidden="true">
                      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm4.64 6.8c-.15 1.58-.8 5.42-1.13 7.19-.14.75-.42 1-.68 1.03-.58.05-1.02-.38-1.58-.75-.88-.58-1.38-.94-2.23-1.5-.99-.65-.35-1.01.22-1.59.15-.15 2.71-2.48 2.76-2.69a.2.2 0 00-.05-.18c-.06-.05-.14-.03-.21-.02-.09.02-1.49.95-4.22 2.79-.4.27-.76.41-1.08.4-.36-.01-1.04-.2-1.55-.37-.63-.2-1.12-.31-1.08-.66.02-.18.27-.36.74-.55 2.92-1.27 4.86-2.11 5.83-2.51 2.79-1.16 3.37-1.36 3.73-1.36.08 0 .27.02.39.12.1.08.13.19.14.27-.01.06.01.24 0 .38z"/>
                    </svg>
                  </span>
                  <span className="text-[10px] font-semibold leading-none">Telegram</span>
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
                  aria-label="Solscan"
                >
                  <span className="flex h-6 w-6 items-center justify-center rounded-full bg-white/5 shadow-[0_0_12px_rgba(59,130,246,0.18)]">
                    <svg viewBox="0 0 24 24" className="h-3.5 w-3.5 text-blue-300" fill="currentColor" aria-hidden="true">
                      <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                    </svg>
                  </span>
                  <span className="text-[10px] font-semibold leading-none">Solscan</span>
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
              <div className="rounded-2xl border border-cyan-400/25 bg-[#061126]/28 p-4 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur sm:p-5">
                <div className="text-2xl sm:text-3xl">🪙</div>
                <div className="mt-2 text-2xl font-extrabold sm:mt-3 sm:text-[32px]">Earn</div>
                <p className="mt-1 text-sm text-blue-100/74 sm:mt-2 sm:text-base">Trade crypto and earn profits.</p>
              </div>
              <div className="rounded-2xl border border-cyan-400/25 bg-[#061126]/28 p-4 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur sm:p-5">
                <div className="text-2xl sm:text-3xl">💛</div>
                <div className="mt-2 text-2xl font-extrabold sm:mt-3 sm:text-[32px]">Help</div>
                <p className="mt-1 text-sm text-blue-100/74 sm:mt-2 sm:text-base">Help children every transaction.</p>
              </div>
              {/* removed: Impact card */}
              <div className="rounded-2xl border border-cyan-400/25 bg-[#061126]/28 p-4 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur sm:p-5 sm:col-span-2 lg:col-span-1">
                <div className="text-xs text-blue-100/72 sm:text-sm">Market Cap</div>
                <div className="mt-2 text-3xl font-extrabold sm:mt-3 sm:text-4xl">$3,250,000</div>
                <div className="mt-2 text-sm text-blue-100/74 sm:mt-3">184 holders</div>
              </div>
            </section>

            <section className="mt-6 sm:mt-8">
              <div className="rounded-2xl border border-cyan-400/25 bg-[#061126]/28 p-4 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur sm:rounded-[26px] sm:p-6">
                <div className="text-2xl font-extrabold sm:text-[34px]">Transparency</div>
                <div className="mt-4 rounded-2xl border border-cyan-400/20 bg-[#08172f]/50 p-4 shadow-[0_0_12px_rgba(56,189,248,0.1)] sm:mt-5 sm:p-5">
                  <div className="text-lg font-bold sm:text-xl">Public Donation Wallet</div>
                  <div className="mt-3 flex flex-col gap-3 sm:mt-4 lg:flex-row lg:items-center lg:justify-between lg:gap-4">
                    <div className="rounded-xl border border-white/10 bg-black/20 px-3 py-2.5 text-sm text-blue-100/80 break-all sm:px-4 sm:py-3 sm:text-base">xxxxxxxxxxxxxxxxxxxxxxxx</div>
                    <button className="rounded-xl bg-blue-600 px-4 py-3 font-bold transition-all duration-200 hover:scale-[1.03] hover:bg-blue-500 active:scale-[0.98] sm:px-5 shrink-0">View on Solscan</button>
                  </div>
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
    </>
  );
}
