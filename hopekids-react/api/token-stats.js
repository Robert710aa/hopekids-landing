const HKIDS_MINT = '6u5PLy9ePpuGEBK3kmQ9isVDFjqSurKpvmCFzheDgQke';

export default async function handler(req, res) {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

  const key = process.env.BIRDEYE_API_KEY;
  if (!key) {
    res.status(200).json({ holder: null });
    return;
  }

  try {
    const url = new URL('https://public-api.birdeye.so/defi/token_overview');
    url.searchParams.set('address', HKIDS_MINT);
    const r = await fetch(url.toString(), {
      headers: {
        accept: 'application/json',
        'x-chain': 'solana',
        'X-API-KEY': key,
      },
    });
    if (!r.ok) {
      res.status(200).json({ holder: null });
      return;
    }
    const j = await r.json();
    const h = j?.data?.holder;
    const n = typeof h === 'number' ? h : h != null ? parseInt(String(h), 10) : NaN;
    res.status(200).json({ holder: Number.isFinite(n) ? n : null });
  } catch {
    res.status(200).json({ holder: null });
  }
}
