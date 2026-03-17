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
            <section className="relative overflow-hidden rounded-[28px] border border-blue-300/15 bg-[linear-gradient(180deg,rgba(4,10,25,0.25),rgba(3,7,18,0.38))] shadow-2xl shadow-black/30 px-8 py-16 lg:px-12 lg:py-20">
              <div className="absolute bottom-0 left-0 right-0 h-32 bg-[linear-gradient(180deg,transparent,rgba(0,0,0,0.35))]" />
              <div className="absolute right-24 top-10 h-[320px] w-[320px] rounded-full bg-[radial-gradient(circle,rgba(59,130,246,0.45),transparent_60%)] blur-2xl animate-pulse" />

              <div className="relative z-10 grid items-center gap-10 lg:grid-cols-2">
                <div>
                  <h1 className="text-5xl font-extrabold">HopeKids</h1>

                  <p className="mt-6 text-2xl font-semibold text-blue-100">
                    Trade Crypto. Give Hope.<br />Help Children.
                  </p>

                  <p className="mt-6 max-w-xl text-blue-200">
                    Each transaction saves tokens to help children.
                    <br />
                    5% of every transaction goes to the public donation wallet.
                  </p>

                  <div className="mt-8 flex gap-4">
                    <button className="rounded-xl bg-blue-600 px-6 py-3 font-bold hover:bg-blue-500">
                      Buy Token
                    </button>

                    <button className="rounded-xl border border-white/30 px-6 py-3 font-bold hover:bg-white/10">
                      View Donation Wallet
                    </button>
                  </div>
                </div>

                <div className="flex justify-center lg:justify-end animate-[float_6s_ease-in-out_infinite]">
                  <div className="relative flex h-[360px] w-[360px] items-center justify-center">
                    <div className="absolute inset-0 rounded-full bg-[radial-gradient(circle,rgba(255,166,0,0.32),transparent_62%)] blur-3xl" />
                    <div className="absolute right-6 top-4 h-[300px] w-[300px] rounded-full bg-[radial-gradient(circle,rgba(56,189,248,0.28),transparent_65%)] blur-2xl" />
                    <div className="relative z-10 h-[260px] w-[260px] overflow-hidden rounded-full bg-transparent">
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
              <div className="relative z-10 mt-10 grid w-full grid-cols-4 gap-3">
                <a
                  href="#"
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-lg border border-cyan-400/25 bg-[#061126]/28 px-1.5 py-2 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur transition hover:border-cyan-400/40 hover:bg-[#071a35]/35 hover:shadow-[0_0_18px_rgba(56,189,248,0.18)]"
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
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-lg border border-cyan-400/25 bg-[#061126]/28 px-1.5 py-2 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur transition hover:border-cyan-400/40 hover:bg-[#071a35]/35 hover:shadow-[0_0_18px_rgba(56,189,248,0.18)]"
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
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-lg border border-cyan-400/25 bg-[#061126]/28 px-1.5 py-2 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur transition hover:border-cyan-400/40 hover:bg-[#071a35]/35 hover:shadow-[0_0_18px_rgba(56,189,248,0.18)]"
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
                  className="group flex min-w-0 flex-col items-center justify-center gap-1 rounded-lg border border-cyan-400/25 bg-[#061126]/28 px-1.5 py-2 text-blue-100/90 shadow-[0_0_14px_rgba(56,189,248,0.12)] backdrop-blur transition hover:border-cyan-400/40 hover:bg-[#071a35]/35 hover:shadow-[0_0_18px_rgba(56,189,248,0.18)]"
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
                <div key={item.label} className="rounded-2xl border border-blue-300/20 bg-[#071226]/28 px-6 py-5 shadow-lg shadow-black/20 backdrop-blur">
                  <div className="text-sm text-blue-100/72">{item.label}</div>
                  <div className="mt-3 flex items-end gap-2">
                    <span className="text-4xl font-extrabold tracking-tight">{item.value}</span>
                    {item.suffix ? <span className="pb-1 text-lg font-semibold text-blue-100/80">{item.suffix}</span> : null}
                  </div>
                </div>
              ))}
            </section>

            {/* removed: Where HopeKids Helps / Trade cards */}

            <section className="mt-8 grid gap-4 lg:grid-cols-[1fr_1fr_1fr_0.9fr]">
              <div className="rounded-2xl border border-blue-300/18 bg-[#061126]/28 p-5 backdrop-blur">
                <div className="text-3xl">🪙</div>
                <div className="mt-3 text-[32px] font-extrabold">Earn</div>
                <p className="mt-2 text-blue-100/74">Trade crypto and earn profits.</p>
              </div>
              <div className="rounded-2xl border border-blue-300/18 bg-[#061126]/28 p-5 backdrop-blur">
                <div className="text-3xl">💛</div>
                <div className="mt-3 text-[32px] font-extrabold">Help</div>
                <p className="mt-2 text-blue-100/74">Help children every transaction.</p>
              </div>
              {/* removed: Impact card */}
              <div className="rounded-2xl border border-blue-300/18 bg-[#061126]/28 p-5 backdrop-blur">
                <div className="text-sm text-blue-100/72">Market Cap</div>
                <div className="mt-3 text-4xl font-extrabold">$3,250,000</div>
                <div className="mt-3 text-blue-100/74">184 holders</div>
              </div>
            </section>

            <section className="mt-8 grid gap-6 lg:grid-cols-[1.05fr]">
              <div className="rounded-[26px] border border-blue-300/18 bg-[#061126]/28 p-6 backdrop-blur">
                <div className="text-[34px] font-extrabold">Transparency</div>
                <div className="mt-5 rounded-2xl border border-white/10 bg-[#08172f]/50 p-5">
                  <div className="text-xl font-bold">Public Donation Wallet</div>
                  <div className="mt-4 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
                    <div className="rounded-xl border border-white/10 bg-black/20 px-4 py-3 text-blue-100/80">xxxxxxxxxxxxxxxxxxxxxxxx</div>
                    <button className="rounded-xl bg-blue-600 px-5 py-3 font-bold transition hover:bg-blue-500">View on Solscan</button>
                  </div>
                </div>
              </div>
            </section>

            <footer className="py-10 text-center text-blue-100/70">
              <div className="text-3xl font-extrabold text-white">HopeKids © 2026</div>
              <div className="mt-2 text-lg">Trade crypto. Give hope.</div>
            </footer>
          </div>
        </div>
      </div>
    </>
  );
}
