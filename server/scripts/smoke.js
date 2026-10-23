const baseUrl = process.argv.find(arg => arg.startsWith('--base='))?.split('=')[1] || 'http://localhost:3000';

async function runSmoke() {
  console.log(`💨 Starting smoke test against ${baseUrl}...`);

  // 1. Health
  const healthRes = await fetch(`${baseUrl}/api/v1/health`);
  const healthJson = await healthRes.json();
  if (!healthRes.ok || !healthJson.success) {
    throw new Error(`Health check failed: ${JSON.stringify(healthJson)}`);
  }
  console.log('✅ Health check: OK');

  // 2. Meta
  const metaRes = await fetch(`${baseUrl}/api/v1/meta`);
  const metaJson = await metaRes.json();
  if (!metaRes.ok || !metaJson.success) {
    throw new Error(`Meta check failed: ${JSON.stringify(metaJson)}`);
  }
  console.log(`✅ Meta check: Phase ${metaJson.data.phase}, ${metaJson.data.components.length} components`);

  // 3. Categories
  const catRes = await fetch(`${baseUrl}/api/v1/categories`);
  const catJson = await catRes.json();
  if (!catRes.ok || !catJson.success || !Array.isArray(catJson.data)) {
    throw new Error(`Categories fetch failed: ${JSON.stringify(catJson)}`);
  }
  console.log(`✅ Categories: ${catJson.data.length} categories loaded`);

  // 4. Search
  const searchRes = await fetch(`${baseUrl}/api/v1/search?q=madh`);
  const searchJson = await searchRes.json();
  if (!searchRes.ok || !searchJson.success) {
    throw new Error(`Search failed: ${JSON.stringify(searchJson)}`);
  }
  console.log(`✅ Search: ${searchJson.data.listings.length} listings returned for query 'madh'`);

  console.log('🎉 Smoke test passed successfully!');
}

runSmoke().catch(err => {
  console.error('❌ Smoke test failed:', err);
  process.exit(1);
});
