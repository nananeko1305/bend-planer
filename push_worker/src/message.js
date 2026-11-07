// The text, dates and shape of the pushes: no I/O, so they can be tested
// alone.

const TIME_ZONE = 'Europe/Belgrade';

// FCM refuses a message over 4 KB; this leaves room for the rest of it.
const MAX_BODY_BYTES = 3000;

const HOUR_S = 60 * 60;

function partsInBelgrade(date, options) {
  const format = new Intl.DateTimeFormat('en-GB', {
    timeZone: TIME_ZONE,
    ...options,
  });
  return Object.fromEntries(
    format.formatToParts(date).map((part) => [part.type, part.value]),
  );
}

/** The day [date] falls on in Belgrade, as yyyy-MM-dd. */
export function dayInBelgrade(date) {
  const { year, month, day } = partsInBelgrade(date, {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
  return `${year}-${month}-${day}`;
}

/** The hour (0-23) on the clock in Belgrade at [date]. */
export function hourInBelgrade(date) {
  return Number(
    partsInBelgrade(date, { hour: '2-digit', hourCycle: 'h23' }).hour,
  );
}

/** [day] moved by [n] days, both as yyyy-MM-dd; calendar days, no clocks. */
export function addDays(day, n) {
  const [y, m, d] = day.split('-').map(Number);
  const moved = new Date(Date.UTC(y, m - 1, d + n));
  return moved.toISOString().slice(0, 10);
}

/** "2026-11-14" as a title shows it: "14.11." */
export function dateLabel(day) {
  const [, month, date] = day.split('-').map(Number);
  return `${date}.${month}.`;
}

/** "2026-10" as a title shows it: "10.2026." */
export function monthLabel(month) {
  const [year, m] = month.split('-').map(Number);
  return `${m}.${year}.`;
}

/** 150000 EUR -> "1.500 €"; 1250050 RSD -> "12.500,50 RSD". */
export function formatMoney(minor, currency) {
  const whole = Math.trunc(minor / 100);
  const cents = minor % 100;
  const grouped = String(whole).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  const number = cents === 0 ? grouped : `${grouped},${String(cents).padStart(2, '0')}`;
  return currency === 'RSD' ? `${number} RSD` : `${number} €`;
}

/** Sums per currency as one line: "9.850 € · 60.000 RSD". */
export function formatSums(sums) {
  const parts = ['EUR', 'RSD']
    .filter((c) => (sums[c] ?? 0) > 0)
    .map((c) => formatMoney(sums[c], c));
  return parts.length > 0 ? parts.join(' · ') : formatMoney(0, 'EUR');
}

/** "Sala Kristal, Kraljevo · 20:00 · 1.500 €": a gig in one line. */
export function gigLine(gig, { withPrice = true } = {}) {
  const place = [gig.venue, gig.city].filter((s) => s).join(', ');
  return [
    place,
    gig.start,
    withPrice ? formatMoney(gig.priceMinor ?? 0, gig.currency) : '',
  ]
    .filter((s) => s)
    .join(' · ');
}

/** One line per entry, cut short when FCM would refuse the message. */
export function listBody(lines) {
  const encoder = new TextEncoder();
  const kept = [];
  let bytes = 0;
  for (const line of lines) {
    bytes += encoder.encode(line).length + 1;
    if (bytes > MAX_BODY_BYTES) {
      kept.push('…');
      break;
    }
    kept.push(line);
  }
  return kept.join('\n');
}

// Per kind: the title resource in the app (see res/values*/strings.xml), the
// Android channel (MainActivity.kt), and how long it is worth delivering.
const KINDS = {
  gigNew: { title: 'gig_new_title', channel: 'gigs', ttl: 2 * 24 * HOUR_S },
  gigChanged: { title: 'gig_changed_title', channel: 'gigs', ttl: 2 * 24 * HOUR_S },
  gigCancelled: { title: 'gig_cancelled_title', channel: 'gigs', ttl: 2 * 24 * HOUR_S },
  tip: { title: 'tip_entered_title', channel: 'tips', ttl: 2 * 24 * HOUR_S },
  tomorrow: { title: 'gig_tomorrow_title', channel: 'reminders', ttl: 12 * HOUR_S },
  today: { title: 'gig_today_title', channel: 'reminders', ttl: 10 * HOUR_S },
  tipReminder: { title: 'tip_reminder_title', channel: 'reminders', ttl: 12 * HOUR_S },
  report: { title: 'report_title', channel: 'reports', ttl: 3 * 24 * HOUR_S },
  memberAdded: { title: 'member_added_title', channel: 'band', ttl: 3 * 24 * HOUR_S },
  memberRemoved: { title: 'member_removed_title', channel: 'band', ttl: 3 * 24 * HOUR_S },
  feedback: { title: 'feedback_title', channel: 'band', ttl: 7 * 24 * HOUR_S },
};

export const KIND_NAMES = Object.keys(KINDS);

/**
 * The FCM message for [kind]. The title is a string resource, so each phone
 * shows it in its own language; [arg] fills its %1$s. [bodyArgs] makes the
 * body a resource too (the report); otherwise [text] is the body as is. Every
 * value is a string: FCM refuses anything else in data and loc args.
 */
export function message(kind, { arg = '', text = '', gigId = '', bodyArgs = null }) {
  const spec = KINDS[kind];
  if (!spec) throw new Error(`Unknown push kind ${kind}`);
  const notification = {
    title_loc_key: spec.title,
    channel_id: spec.channel,
  };
  if (arg) notification.title_loc_args = [String(arg)];
  if (bodyArgs) {
    notification.body_loc_key = 'report_body';
    notification.body_loc_args = bodyArgs.map(String);
  } else {
    notification.body = text;
  }
  // The app shows `text` while open; for a report it is the numbers alone.
  const shown = bodyArgs ? bodyArgs.join(' · ') : text;
  return {
    data: { type: 'band', kind, gigId: String(gigId), arg: String(arg), text: String(shown) },
    android: { priority: 'high', ttl: `${spec.ttl}s`, notification },
  };
}
