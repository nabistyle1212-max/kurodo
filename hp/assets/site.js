/* 陽 -Akari- オフィシャルサイト 共通スクリプト */
(function () {
  'use strict';

  /* ── スマホ用ドロワーメニュー ── */
  var toggle = document.querySelector('.nav-toggle');
  var drawer = document.getElementById('drawer');

  if (toggle && drawer) {
    toggle.addEventListener('click', function () {
      var open = toggle.getAttribute('aria-expanded') === 'true';
      toggle.setAttribute('aria-expanded', String(!open));
      drawer.hidden = open;
      document.body.style.overflow = open ? '' : 'hidden';
    });

    // ドロワー内のリンクを押したら閉じる
    drawer.addEventListener('click', function (e) {
      if (e.target.closest('a')) {
        toggle.setAttribute('aria-expanded', 'false');
        drawer.hidden = true;
        document.body.style.overflow = '';
      }
    });

    // Escキーで閉じる
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && !drawer.hidden) {
        toggle.setAttribute('aria-expanded', 'false');
        drawer.hidden = true;
        document.body.style.overflow = '';
        toggle.focus();
      }
    });

    // PC幅に広がったら閉じる
    window.addEventListener('resize', function () {
      if (window.innerWidth >= 1000 && !drawer.hidden) {
        toggle.setAttribute('aria-expanded', 'false');
        drawer.hidden = true;
        document.body.style.overflow = '';
      }
    });
  }

  /* ── スクロールで要素をふわっと表示 ── */
  var reveals = document.querySelectorAll('.reveal');
  if (reveals.length) {
    if ('IntersectionObserver' in window) {
      var observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            observer.unobserve(entry.target);
          }
        });
      }, { threshold: 0.08 });
      reveals.forEach(function (el) { observer.observe(el); });
    } else {
      reveals.forEach(function (el) { el.classList.add('visible'); });
    }
  }

  /* ── 予約ボタンのクリックを計測（LPと同じ設定） ── */
  document.addEventListener('click', function (e) {
    var link = e.target.closest('a[href*="reservia.jp"]');
    if (!link) { return; }
    if (typeof gtag === 'function') {
      gtag('event', 'conversion', { send_to: 'AW-16780956151/7MZiCP7Cg9UcEPej5ME-' });
    }
    if (typeof fbq === 'function') {
      fbq('track', 'Lead');
    }
  });
})();
