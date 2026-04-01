/**
 * Vercel serverless: recent signatures for the public donation wallet (Solana mainnet).
 * Optional env: DONATION_WALLET_ADDRESS (defaults to HopeKids public wallet).
 */
const DEFAULT_WALLET = 'GnhmPt4LBHRoABuGrSqrbPW34Mu8dXGJf1XCNc7DHRAB';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  if (req.method === 'OPTIONS') return res.status(204).end();
  if (req.method !== 'GET') return res.status(405).json({ ok: false, items: [] });

  res.setHeader('Cache-Control', 's-maxage=90, stale-while-revalidate=300');

  const wallet = process.env.DONATION_WALLET_ADDRESS || DEFAULT_WALLET;

  try {
    const body = JSON.stringify({
      jsonrpc: '2.0',
      id: 1,
      method: 'getSignaturesForAddress',
      params: [wallet, { limit: 8 }],
    });
    const r = await fetch('https://api.mainnet-beta.solana.com', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body,
    });
    const json = await r.json();
    const sigs = Array.isArray(json?.result) ? json.result : [];
    const items = sigs.map((s) => ({
      signature: s.signature,
      slot: s.slot,
      err: s.err,
      blockTime: s.blockTime ?? null,
    }));
    return res.status(200).json({ ok: true, items });
  } catch {
    return res.status(200).json({ ok: false, items: [], error: 'rpc_failed' });
  }
}
