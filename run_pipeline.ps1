Write-Host "=== [1/3] MENJALANKAN 200 UNIT TESTS (Branch: v1.0_dev) ===" -ForegroundColor Cyan
flutter test test/p11_200_unit_test.dart

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[PIPELINE STOPPED] Unit Test FAILED! Auto-Build & Deploy DIBATALKAN." -ForegroundColor Red
    exit 1
}

Write-Host "`n=== [2/3] ALL 200 UNIT TESTS PASSED (HIJAU) -> AUTO BUILD APK ===" -ForegroundColor Green
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== [3/3] BUILD SUKSES -> SIAP DEPLOY KE LIVE / BRANCH V1.1 ===" -ForegroundColor Green
}
