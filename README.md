# Herning Ejendomsvedligeholdelse

Mobilvenlig webapp til administration, rengøringskalender, kunder, fakturaer og regnskab.

## Status

Version 0.1 indeholder en mobilvenlig skal og Supabase magic-link-login. Forretningsmodulerne er endnu ikke aktive. Ingen regnskabsdata gemmes på nuværende tidspunkt.

## Opsætning

1. Upload `index.html` til roden af GitHub-repositoryet.
2. Deploy som statisk site med Vercel.
3. Tilføj Vercel-URL'en under Supabase Authentication → URL Configuration → Redirect URLs, uden at fjerne pakkeshoppens URLs.
4. Indtast Supabase Project URL og offentlig publishable/anon key i appen.
5. Log ind med din eksisterende Supabase-bruger.

**Sikkerhed:** Brug aldrig `service_role` eller secret keys i browseren. Opret separate `hev_`-tabeller med RLS og privat storage før du gemmer kunder, kvitteringer eller fakturaer. Login alene sikrer ikke adgangskontrol.
