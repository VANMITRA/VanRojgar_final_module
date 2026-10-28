export default function App() {
  return (
    <div
      style={{
        backgroundColor: '#121212',
        color: '#E0E0E0',
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '32px',
        fontFamily: 'system-ui, -apple-system, sans-serif',
      }}
    >
      <div
        style={{
          maxWidth: '560px',
          width: '100%',
          backgroundColor: '#1E1E1E',
          borderRadius: '16px',
          padding: '32px',
          border: '1px solid #333',
          boxShadow: '0 8px 32px rgba(0,0,0,0.5)',
          textAlign: 'center',
        }}
      >
        <div style={{ fontSize: '40px', marginBottom: '16px' }}>📦</div>
        <h1 style={{ fontSize: '24px', fontWeight: 'bold', margin: '0 0 8px 0', color: '#FFF' }}>
          VanRozgar Phase 1 UI (Flutter)
        </h1>
        <p style={{ color: '#AAA', fontSize: '14px', margin: '0 0 24px 0', lineHeight: '1.5' }}>
          All 15 Flutter Dart files packaged and ready to extract into your <code>app/lib/</code> folder.
        </p>

        <a
          href="/ui_v2.zip"
          download="ui_v2.zip"
          style={{
            display: 'inline-block',
            backgroundColor: '#4E7A3A',
            color: '#FFF',
            textDecoration: 'none',
            fontWeight: 'bold',
            fontSize: '16px',
            padding: '16px 32px',
            borderRadius: '999px',
            boxShadow: '0 4px 12px rgba(78, 122, 58, 0.4)',
            transition: 'background-color 0.2s',
          }}
        >
          ⬇️ Download ui_v2.zip (All 15 Files)
        </a>

        <div style={{ marginTop: '28px', textAlign: 'left', borderTop: '1px solid #333', paddingTop: '20px' }}>
          <p style={{ fontSize: '12px', color: '#888', fontWeight: '600', margin: '0 0 10px 0', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
            What to do with this zip:
          </p>
          <ol style={{ fontSize: '13px', color: '#BBB', margin: 0, paddingLeft: '20px', lineHeight: '1.6' }}>
            <li>Download <code>ui_v2.zip</code>.</li>
            <li>Extract the <code>ui_v2</code> folder into your project's <code>app/lib/</code> directory.</li>
            <li>Run <code>flutter run -t lib/ui_v2/main_demo.dart</code> in your terminal.</li>
          </ol>
        </div>
      </div>
    </div>
  );
}
