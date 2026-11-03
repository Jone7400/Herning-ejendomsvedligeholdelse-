# Herning Ejendomsvedligeholdelse v1.0.0

Mobilvenlig webapp med samme Supabase-login som Østergades Pakkeshop, men egne `hev_`-tabeller.

## Opsætning
1. Find dit Supabase bruger-ID under **Authentication → Users** i projekt `paqeijcqyjvsehnxzwgw`.
2. Åbn `supabase_setup.sql` og erstat `00000000-0000-0000-0000-000000000000` med dit UUID. Kør derefter scriptet i **Supabase → SQL Editor**. Dette er nødvendigt én gang, før data kan gemmes. Gem ikke dit UUID som en adgangskode; det er kun en identifikator.
3. Upload `index.html` til roden af GitHub-repositoryet. Vercel opdaterer automatisk.
4. Log ind med samme e-mail og adgangskode som før. Den offentlige Supabase-nøgle er normalt allerede gemt på den pågældende enhed.

## Funktioner
Kundekartotek, rengøringskalender med 200 kr. standardpris, opgaver med timer/materialer, fakturaer med PDF via browserens udskrivning, privat bilagsarkiv, momsoverslag, CSV-eksport og månedsrapport. Versionsnummer vises øverst til højre.

## Vigtige afgrænsninger
- Ingen e-mailafsendelse og ingen automatisk kvitteringsaflæsning i denne version.
- Faktura-PDF genereres via **Udskriv / Gem som PDF**; månedsrapporten er en økonomisk oversigt og indeholder ikke automatisk alle bilag.
- Momsberegning og resultat er vejledende og erstatter ikke bogføring eller skatterådgivning.
- Sletning af en kunde med tilknyttede registreringer blokeres af databasen.
- Opbevar sikkerhedskopier af fakturaer og bilag. Kontroller lovpligtige fakturaoplysninger, herunder din virksomheds adresse og CVR, før du sender fakturaer.
