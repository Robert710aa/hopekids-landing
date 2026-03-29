import { useCallback, useState } from 'react';

const PUBLIC_DONATION_WALLET = 'GnhmPt4LBHRoABuGrSqrbPW34Mu8dXGJf1XCNc7DHRAB';
const HOPEKIDS_TEAM_EMAIL = 'hopekids594@gmail.com';

export default function HopeKidsLandingPage() {
  const [walletCopied, setWalletCopied] = useState(false);

  const copyDonationWallet = useCallback(async () => {
    try {
      await navigator.clipboard.writeText(PUBLIC_DONATION_WALLET);
      setWalletCopied(true);
      window.setTimeout(() => setWalletCopied(false), 2000);
    } catch {
      /* ignore */
    }
  }, []);

  const stats = [
    { label: 'Tokens Saved for Children', value: '3,245,678', suffix: 'HKIDS' },
    { label: 'Current Value', value: '$16,380', suffix: '' },
    { label: 'Total Transactions Helping Children', value: '15,284', suffix: '' },
  ];

  const topHelpers = [
    { name: 'Wallet 1', amount: '450,000 HKIDS' },
    { name: 'Wallet 2', amount: '310,000 HKIDS' },
  ];

  const community = ['TikTok', 'Twitter', 'DexScreener', 'Facebook'];

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

          {/* Logo w prawym górnym rogu strony (fixed) */}
          <div className="fixed right-4 top-4 z-50 flex h-14 w-14 items-center justify-center rounded-full border-2 border-amber-300/50 bg-[#061126]/45 shadow-lg shadow-amber-500/20 backdrop-blur md:right-6 md:top-6 md:h-16 md:w-16">
            <img
              src="/hopekids-coin.png"
              alt="HopeKids"
              className="h-full w-full rounded-full object-contain p-0.5"
            />
          </div>

          <div className="relative z-10 mx-auto max-w-[1180px] px-4 py-4 sm:px-6 lg:px-8">
            <header className="mb-6 flex items-center justify-between rounded-2xl border border-blue-400/20 bg-[#061126]/45 px-4 py-3 backdrop-blur">
              <div className="flex items-center gap-3">
                <div className="flex h-11 w-11 items-center justify-center rounded-full border border-amber-300/50 bg-gradient-to-br from-amber-300 to-amber-600 shadow-lg shadow-amber-500/20 overflow-hidden">
                  <img src="/hopekids-coin.png" alt="HopeKids" className="h-full w-full object-contain" />
                </div>
                <div className="text-2xl font-extrabold tracking-tight">HopeKids</div>
              </div>

              <nav className="hidden items-center gap-7 text-sm font-medium text-blue-100/85 md:flex">
                <a href="#" className="hover:text-white">Home</a>
                <a href="#" className="hover:text-white">Why HopeKids</a>
                <a href="#" className="hover:text-white">Transparency</a>
                <a href="#" className="hover:text-white">Donations</a>
                <a href="#" className="hover:text-white">Community</a>
              </nav>

              <button className="rounded-xl border border-blue-300/40 bg-blue-600/20 px-5 py-3 font-semibold text-white shadow-lg shadow-blue-900/30 transition hover:bg-blue-600/30">
                Buy HKIDS
              </button>
            </header>

            <section className="relative overflow-hidden rounded-[28px] border border-blue-300/15 bg-[linear-gradient(180deg,rgba(4,10,25,0.4),rgba(3,7,18,0.55))] shadow-2xl shadow-black/30 px-8 py-16 lg:px-12 lg:py-20">
              <div className="absolute bottom-0 left-0 right-0 h-32 bg-[linear-gradient(180deg,transparent,rgba(0,0,0,0.6))]" />
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
                    <div className="relative z-10 h-[320px] w-[320px] overflow-hidden rounded-full border border-amber-200/40 shadow-[0_0_80px_rgba(255,190,80,0.35)]">
                      <div className="absolute inset-[-10px] rounded-full bg-[radial-gradient(circle_at_30%_25%,rgba(255,245,200,0.35),transparent_38%),radial-gradient(circle_at_70%_65%,rgba(59,130,246,0.25),transparent_45%)] blur-md" />
                      <img
                        src="/hopekids-coin.png"
                        alt="HopeKids Coin"
                        className="relative z-10 h-full w-full object-cover [animation:coinRotate_24s_linear_infinite]"
                      />
                      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_50%_20%,rgba(255,255,255,0.18),transparent_35%),radial-gradient(circle_at_50%_100%,rgba(0,0,0,0.25),transparent_45%)]" />
                      <div className="pointer-events-none absolute left-1/2 top-[-20%] h-[140%] w-[22%] -translate-x-1/2 bg-[linear-gradient(90deg,transparent,rgba(255,255,255,0.55),transparent)] blur-md [animation:shineSweep_6s_ease-in-out_infinite]" />
                    </div>
                  </div>
                </div>
              </div>
            </section>

            <section className="mt-6 grid gap-4 md:grid-cols-3">
              {stats.map((item) => (
                <div key={item.label} className="rounded-2xl border border-blue-300/20 bg-[#071226]/45 px-6 py-5 shadow-lg shadow-black/20 backdrop-blur">
                  <div className="text-sm text-blue-100/72">{item.label}</div>
                  <div className="mt-3 flex items-end gap-2">
                    <span className="text-4xl font-extrabold tracking-tight">{item.value}</span>
                    {item.suffix ? <span className="pb-1 text-lg font-semibold text-blue-100/80">{item.suffix}</span> : null}
                  </div>
                </div>
              ))}
            </section>

            <section className="mt-8 grid gap-6 lg:grid-cols-[1.35fr_0.75fr]">
              <div className="rounded-[26px] border border-blue-300/18 bg-[#061126]/45 p-6 backdrop-blur">
                <div className="mb-5 text-center text-[34px] font-extrabold">Where HopeKids Helps</div>
                <div className="relative h-[330px] overflow-hidden rounded-[22px] border border-white/10 bg-[radial-gradient(circle_at_50%_45%,rgba(59,130,246,0.12),transparent_35%),linear-gradient(180deg,rgba(7,20,39,0.5),rgba(3,10,24,0.55))]">
                  <div className="absolute left-[16%] top-[44%] h-4 w-4 rounded-full bg-orange-400 shadow-[0_0_24px_rgba(251,146,60,1)]" />
                  <div className="absolute left-[45%] top-[40%] h-4 w-4 rounded-full bg-amber-300 shadow-[0_0_24px_rgba(251,191,36,1)]" />
                  <div className="absolute left-[62%] top-[46%] h-4 w-4 rounded-full bg-amber-300 shadow-[0_0_24px_rgba(251,191,36,1)]" />
                  <div className="absolute left-[16%] top-[44%] h-px w-[30%] origin-left rotate-[-7deg] bg-gradient-to-r from-amber-400 to-transparent" />
                  <div className="absolute left-[45%] top-[40%] h-px w-[18%] origin-left rotate-[10deg] bg-gradient-to-r from-amber-400 to-transparent" />
                  <div className="absolute bottom-5 left-0 right-0 flex justify-center gap-5 text-sm font-semibold sm:gap-10">
                    <div className="rounded-full border border-white/10 bg-black/20 px-4 py-2">Germany</div>
                    <div className="rounded-full border border-white/10 bg-black/20 px-4 py-2">Poland</div>
                    <div className="rounded-full border border-white/10 bg-black/20 px-4 py-2">USA</div>
                  </div>
                </div>
              </div>

              <div className="rounded-[26px] border border-blue-300/18 bg-[#061126]/45 p-6 backdrop-blur">
                <div className="text-[32px] font-extrabold leading-tight">Trade HopeKids Helps</div>
                <div className="mt-5 space-y-4">
                  <div className="rounded-xl border border-white/10 bg-[#08172f]/60 px-4 py-4 text-lg font-semibold">100000 HKIDS</div>
                  <div className="rounded-2xl border border-blue-300/18 bg-[linear-gradient(180deg,rgba(16,63,140,0.25),rgba(9,20,40,0.45))] px-5 py-6">
                    <div className="text-sm text-blue-100/72">5% goes to helping children</div>
                    <div className="mt-2 text-5xl font-extrabold">5,000 <span className="text-2xl text-blue-100/85">HKIDS</span></div>
                  </div>
                  <button className="w-full rounded-xl bg-[linear-gradient(90deg,#8a5a18,#f4b84d)] px-5 py-4 text-lg font-extrabold text-slate-950 transition hover:opacity-90">
                    Next Step
                  </button>
                </div>
              </div>
            </section>

            <section className="mt-8 grid gap-4 lg:grid-cols-[1fr_1fr_1fr_0.9fr]">
              <div className="rounded-2xl border border-blue-300/18 bg-[#061126]/45 p-5 backdrop-blur">
                <div className="text-3xl">🪙</div>
                <div className="mt-3 text-[32px] font-extrabold">Earn</div>
                <p className="mt-2 text-blue-100/74">Trade crypto and earn profits.</p>
              </div>
              <div className="rounded-2xl border border-blue-300/18 bg-[#061126]/45 p-5 backdrop-blur">
                <div className="text-3xl">💛</div>
                <div className="mt-3 text-[32px] font-extrabold">Help</div>
                <p className="mt-2 text-blue-100/74">Help children every transaction.</p>
              </div>
              <div className="rounded-2xl border border-blue-300/18 bg-[#061126]/45 p-5 backdrop-blur">
                <div className="text-3xl">🌍</div>
                <div className="mt-3 text-[32px] font-extrabold">Impact</div>
                <p className="mt-2 text-blue-100/74">Make a difference worldwide.</p>
              </div>
              <div className="rounded-2xl border border-blue-300/18 bg-[#061126]/45 p-5 backdrop-blur">
                <div className="text-sm text-blue-100/72">Market Cap</div>
                <div className="mt-3 text-4xl font-extrabold">$3,250,000</div>
                <div className="mt-3 text-blue-100/74">184 holders</div>
              </div>
            </section>

            <section className="mt-8 grid gap-6 lg:grid-cols-[1.05fr_0.95fr]">
              <div className="rounded-[26px] border border-blue-300/18 bg-[#061126]/45 p-6 backdrop-blur">
                <div className="text-[34px] font-extrabold">Transparency</div>
                <div className="mt-5 rounded-2xl border border-white/10 bg-[#08172f]/55 p-5">
                  <div className="text-xl font-bold">Public Donation Wallet</div>
                  <div className="mt-4 flex flex-col gap-4 lg:flex-row lg:items-stretch lg:justify-between">
                    <div className="flex min-w-0 flex-1 items-stretch gap-2 rounded-xl border border-white/10 bg-black/20">
                      <div className="min-w-0 flex-1 break-all px-4 py-3 font-mono text-sm text-blue-100/90">
                        {PUBLIC_DONATION_WALLET}
                      </div>
                      <button
                        type="button"
                        onClick={copyDonationWallet}
                        aria-label={walletCopied ? 'Skopiowano' : 'Kopiuj adres portfela'}
                        className="flex shrink-0 items-center justify-center border-l border-white/10 px-4 text-cyan-300 transition hover:bg-white/5 hover:text-cyan-200"
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
                    <button className="rounded-xl bg-blue-600 px-5 py-3 font-bold transition hover:bg-blue-500 lg:shrink-0">
                      View on Facebook
                    </button>
                  </div>
                  {walletCopied ? (
                    <p className="mt-2 text-sm font-medium text-emerald-300/90" role="status">
                      Skopiowano do schowka
                    </p>
                  ) : null}
                </div>
              </div>

              <div className="grid gap-6 lg:grid-rows-[auto_auto]">
                <div className="rounded-[26px] border border-blue-300/18 bg-[#061126]/45 p-6 backdrop-blur">
                  <div className="text-[34px] font-extrabold">Top Helpers</div>
                  <div className="mt-5 space-y-4">
                    {topHelpers.map((item) => (
                      <div key={item.name} className="flex items-center justify-between rounded-2xl border border-white/10 bg-[#08172f]/55 px-4 py-4">
                        <div>
                          <div className="text-lg font-bold">{item.name}</div>
                          <div className="text-sm text-blue-100/65">Public supporter</div>
                        </div>
                        <div className="text-right text-xl font-extrabold text-amber-200">{item.amount}</div>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="rounded-[26px] border border-amber-300/18 bg-[linear-gradient(180deg,rgba(67,38,9,0.25),rgba(7,17,38,0.5))] p-6 backdrop-blur">
                  <div className="text-sm font-bold uppercase tracking-[0.2em] text-amber-200/80">Child We Help This Month</div>
                  <div className="mt-4 flex gap-4">
                    <div className="flex h-24 w-24 items-center justify-center rounded-2xl bg-black/20 text-5xl">🧸</div>
                    <div>
                      <div className="text-2xl font-extrabold">Featured Child</div>
                      <div className="mt-2 text-blue-100/74">Visible monthly story and support progress for the community.</div>
                    </div>
                  </div>
                  <button className="mt-5 rounded-xl bg-[linear-gradient(90deg,#8a5a18,#f4b84d)] px-5 py-3 font-extrabold text-slate-950 transition hover:opacity-90">
                    Donate Now
                  </button>
                </div>
              </div>
            </section>

            <section className="mt-8 rounded-[26px] border border-blue-300/18 bg-[#061126]/45 px-6 py-8 text-center backdrop-blur">
              <div className="text-[34px] font-extrabold">Join Our Community</div>
              <div className="mt-6 flex flex-wrap items-center justify-center gap-4">
                {community.map((item) => (
                  <div key={item} className="rounded-xl border border-blue-300/20 bg-white/5 px-6 py-4 font-bold text-blue-100/84">
                    {item}
                  </div>
                ))}
              </div>
            </section>

            <section className="mt-8 grid gap-6 rounded-[26px] border border-blue-300/18 bg-[#061126]/45 p-6 backdrop-blur lg:grid-cols-[0.85fr_1.15fr] lg:items-center">
              <div className="mx-auto flex h-48 w-48 items-center justify-center rounded-full bg-[radial-gradient(circle_at_center,rgba(251,191,36,0.75),rgba(251,191,36,0.14)_42%,transparent_66%)] text-7xl">
                💛
              </div>
              <div>
                <div className="text-[40px] font-extrabold leading-tight">The Story of HopeKids</div>
                <p className="mt-4 max-w-3xl text-lg leading-8 text-blue-100/78">
                  HopeKids was created to combine the power of blockchain with real help for children who need it the most.
                </p>
              </div>
            </section>

            <section
              className="mt-8 rounded-[26px] border border-blue-300/18 bg-[#061126]/45 p-6 backdrop-blur"
              id="contact"
              aria-labelledby="contact-heading"
            >
              <h2 id="contact-heading" className="text-[34px] font-extrabold">
                Kontakt z zespołem
              </h2>
              <p className="mt-3 max-w-3xl text-lg leading-8 text-blue-100/78">
                Pytania, współpraca lub pomoc — napisz do nas. Odpowiadamy na maile związane z HopeKids.
              </p>
              <a
                href={`mailto:${HOPEKIDS_TEAM_EMAIL}`}
                className="mt-5 inline-flex items-center gap-2 rounded-xl border border-blue-300/30 bg-[#08172f]/55 px-5 py-3 text-lg font-semibold text-cyan-200 transition hover:border-cyan-400/40 hover:bg-[#0a1f42]/80"
              >
                <svg viewBox="0 0 24 24" className="h-5 w-5 shrink-0" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
                  <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                  <path d="m22 6-10 7L2 6" />
                </svg>
                {HOPEKIDS_TEAM_EMAIL}
              </a>
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
