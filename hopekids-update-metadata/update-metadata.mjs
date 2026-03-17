/**
 * Update HopeKids (HKD) token metadata on Solana mainnet.
 * Requires: Node 18+, npm install, and WALLET_PATH to your update-authority keypair JSON.
 *
 * Run: set WALLET_PATH=C:\path\to\keypair.json && npm run update
 * (PowerShell: $env:WALLET_PATH="C:\path\to\keypair.json"; npm run update)
 */

import { readFileSync } from 'fs'
import { createUmi } from '@metaplex-foundation/umi-bundle-defaults'
import { keypairIdentity, publicKey } from '@metaplex-foundation/umi'
import {
  fetchDigitalAsset,
  mplTokenMetadata,
  updateV1,
} from '@metaplex-foundation/mpl-token-metadata'

const MINT = '6u5PLy9ePpuGEBK3kmQ9isVDFjqSurKpvmCFzheDgQke'
const NAME = 'HopeKids'
const SYMBOL = 'HKD'
const METADATA_URI =
  'https://tan-adjacent-swordtail-450.mypinata.cloud/ipfs/bafkreic5wyunsrfma7436l2puosckvdswbrbm2cwy5v4jyqksv5gj4ycoi'

const walletPath = process.env.WALLET_PATH
if (!walletPath) {
  console.error(
    'Ustaw WALLET_PATH na ścieżkę do pliku JSON z kluczem (update authority).\n' +
      'PowerShell: $env:WALLET_PATH="C:\\Users\\...\\keypair.json"; npm run update'
  )
  process.exit(1)
}

const umi = createUmi('https://api.mainnet-beta.solana.com').use(
  mplTokenMetadata()
)

const secretKey = JSON.parse(readFileSync(walletPath, 'utf-8'))
const keypair = umi.eddsa.createKeypairFromSecretKey(new Uint8Array(secretKey))
umi.use(keypairIdentity(keypair))

const mintAddress = publicKey(MINT)

async function main() {
  console.log('Pobieranie aktualnych metadanych...')
  const asset = await fetchDigitalAsset(umi, mintAddress)

  console.log('Wysyłanie aktualizacji (name, symbol, uri)...')
  await updateV1(umi, {
    mint: mintAddress,
    authority: umi.identity,
    data: {
      ...asset.metadata,
      name: NAME,
      symbol: SYMBOL,
      uri: METADATA_URI,
    },
  }).sendAndConfirm(umi)

  console.log('Zaktualizowano metadane tokena.')
  console.log('Mint:', MINT)
  console.log('Name:', NAME)
  console.log('Symbol:', SYMBOL)
  console.log('URI:', METADATA_URI)
}

main().catch((e) => {
  console.error(e)
  process.exit(1)
})
