(function () {
  'use strict';

  const STORAGE_KEY = 'crypto-portfolio-holdings';
  const COIN_NAMES = {
    bitcoin: 'BTC', ethereum: 'ETH', tether: 'USDT', binancecoin: 'BNB',
    solana: 'SOL', ripple: 'XRP', cardano: 'ADA', dogecoin: 'DOGE',
    polkadot: 'DOT', 'avalanche-2': 'AVAX', chainlink: 'LINK', polygon: 'MATIC'
  };

  let holdings = [];

  function load() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      holdings = raw ? JSON.parse(raw) : [];
    } catch (_) {
      holdings = [];
    }
  }

  function save() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(holdings));
  }

  function fetchPrices(ids) {
    if (!ids.length) return Promise.resolve({});
    const url = 'https://api.coingecko.com/api/v3/simple/price?ids=' + ids.join(',') + '&vs_currencies=usd,pln';
    return fetch(url).then(function (r) { return r.json(); });
  }

  function formatNum(n) {
    if (n >= 1e9) return n.toFixed(2) + ' mld';
    if (n >= 1e6) return n.toFixed(2) + ' mln';
    if (n >= 1e3) return n.toFixed(2) + ' tys';
    if (n >= 1) return n.toFixed(2);
    if (n >= 0.01) return n.toFixed(4);
    return n.toFixed(6);
  }

  function render(prices) {
    const listEl = document.getElementById('holdings');
    const emptyEl = document.getElementById('emptyMsg');
    const totalUSDE = document.getElementById('totalUSD');
    const totalPLNE = document.getElementById('totalPLN');
    const lastE = document.getElementById('lastUpdate');

    listEl.innerHTML = '';
    let totalUSD = 0, totalPLN = 0;

    holdings.forEach(function (h, i) {
      const p = prices[h.id] || {};
      const usd = (p.usd || 0) * Number(h.amount);
      const pln = (p.pln || 0) * Number(h.amount);
      totalUSD += usd;
      totalPLN += pln;

      const li = document.createElement('li');
      li.innerHTML =
        '<span class="name">' + (COIN_NAMES[h.id] || h.id) + ' <small>' + formatNum(Number(h.amount)) + '</small></span>' +
        '<span><span class="value">' + formatNum(pln) + ' PLN</span><br><span class="usd">' + formatNum(usd) + ' USD</span></span>' +
        '<button type="button" data-i="' + i + '">Usuń</button>';
      listEl.appendChild(li);
    });

    listEl.querySelectorAll('button').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var i = parseInt(btn.getAttribute('data-i'), 10);
        holdings.splice(i, 1);
        save();
        refresh();
      });
    });

    totalUSDE.textContent = formatNum(totalUSD);
    totalPLNE.textContent = formatNum(totalPLN);
    lastE.textContent = prices._updated ? 'Ceny: ' + new Date(prices._updated).toLocaleString('pl-PL') : '—';
    emptyEl.classList.toggle('hidden', holdings.length > 0);
  }

  function refresh() {
    load();
    const ids = [...new Set(holdings.map(function (h) { return h.id; }))];
    fetchPrices(ids).then(function (data) {
      data._updated = Date.now();
      render(data);
    }).catch(function () {
      render({ _updated: null });
    });
  }

  document.getElementById('btnAdd').addEventListener('click', function () {
    var select = document.getElementById('coinSelect');
    var amountEl = document.getElementById('amount');
    var id = select.value;
    var amount = parseFloat(amountEl.value, 10);
    if (!id || !Number.isFinite(amount) || amount <= 0) return;
    holdings.push({ id: id, amount: amount });
    save();
    amountEl.value = '';
    refresh();
  });

  document.getElementById('btnRefresh').addEventListener('click', refresh);

  refresh();
})();
