# 获取脚本所在目录（项目根目录）
$rootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$designMdPath = Join-Path $rootDir "design-md"

# 检查 design-md 目录是否存在
if (-not (Test-Path $designMdPath)) {
    Write-Error "design-md 目录不存在: $designMdPath"
    exit 1
}

# 获取 design-md 下的所有子目录
$folders = Get-ChildItem -Path $designMdPath -Directory | Select-Object -ExpandProperty Name

Write-Host "找到以下文件夹:"
$folders | ForEach-Object { Write-Host "  - $_" }
Write-Host ""

# 遍历每个文件夹并执行命令
foreach ($folder in $folders) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "正在处理: $folder" -ForegroundColor Cyan
    Write-Host "执行目录: $rootDir" -ForegroundColor Gray
    Write-Host "执行命令: npx getdesign@latest add $folder" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan

    # 在根目录执行命令
    try {
        Push-Location $rootDir

        # 执行 npx 命令
        npx getdesign@latest add $folder

        # 移动生成的文件到 design-md 下的对应目录
        $sourceDir = Join-Path $rootDir $folder
        $targetDir = Join-Path $designMdPath $folder

        if (Test-Path $sourceDir) {
            Write-Host "移动文件: $sourceDir -> $targetDir" -ForegroundColor Gray

            # 确保目标目录存在
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }

            # 移动文件
            Get-ChildItem -Path $sourceDir -File | Move-Item -Destination $targetDir -Force

            # 删除空的源目录
            Remove-Item -Path $sourceDir -Recurse -Force

            Write-Host "✅ $folder 处理完成并移动到 design-md/$folder" -ForegroundColor Green
        } else {
            Write-Host "⚠️ 未找到生成的目录: $sourceDir" -ForegroundColor Yellow
        }

        Pop-Location
    }
    catch {
        Write-Error "❌ 处理 $folder 时出错: $_"
        Pop-Location
    }

    Write-Host ""
}

Write-Host "所有文件夹处理完成!" -ForegroundColor Green
