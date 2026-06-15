Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Drawing;
using System.Windows.Forms;
using System.Runtime.InteropServices;

public class SelectionForm : Form {
    [DllImport("user32.dll")]
    static extern bool SetForegroundWindow(IntPtr hWnd);

    private Point startPoint;
    private Point endPoint;
    private bool isSelecting = false;
    public Rectangle SelectedRegion { get; private set; }
    public bool Confirmed { get; private set; } = false;

    public SelectionForm() {
        this.FormBorderStyle = FormBorderStyle.None;
        this.WindowState = FormWindowState.Maximized;
        this.TopMost = true;
        this.Opacity = 0.4;
        this.BackColor = Color.Black;
        this.Cursor = Cursors.Cross;
        this.DoubleBuffered = true;
        this.KeyPreview = true;
        this.KeyDown += (s, e) => { if (e.KeyCode == Keys.Escape) { this.Confirmed = false; this.Close(); } };
    }

    protected override void OnMouseDown(MouseEventArgs e) {
        if (e.Button == MouseButtons.Left) {
            startPoint = e.Location;
            endPoint = e.Location;
            isSelecting = true;
        }
    }

    protected override void OnMouseMove(MouseEventArgs e) {
        if (isSelecting) {
            endPoint = e.Location;
            this.Invalidate();
        }
    }

    protected override void OnMouseUp(MouseEventArgs e) {
        if (e.Button == MouseButtons.Left && isSelecting) {
            isSelecting = false;
            endPoint = e.Location;
            int x = Math.Min(startPoint.X, endPoint.X);
            int y = Math.Min(startPoint.Y, endPoint.Y);
            int w = Math.Abs(endPoint.X - startPoint.X);
            int h = Math.Abs(endPoint.Y - startPoint.Y);
            if (w > 5 && h > 5) {
                SelectedRegion = new Rectangle(x, y, w, h);
                Confirmed = true;
                this.Close();
            }
        }
    }

    protected override void OnPaint(PaintEventArgs e) {
        base.OnPaint(e);
        if (isSelecting) {
            int x = Math.Min(startPoint.X, endPoint.X);
            int y = Math.Min(startPoint.Y, endPoint.Y);
            int w = Math.Abs(endPoint.X - startPoint.X);
            int h = Math.Abs(endPoint.Y - startPoint.Y);
            using (var pen = new Pen(Color.Red, 2))
            using (var brush = new SolidBrush(Color.FromArgb(80, 0, 120, 215))) {
                e.Graphics.FillRectangle(brush, x, y, w, h);
                e.Graphics.DrawRectangle(pen, x, y, w, h);
            }
            string info = $"{w} x {h}";
            using (var font = new Font("Segoe UI", 12, FontStyle.Bold))
            using (var brush = new SolidBrush(Color.White)) {
                e.Graphics.DrawString(info, font, brush, x + 4, y + 4);
            }
        }
        // 全体のガイドテキスト
        using (var font = new Font("Segoe UI", 14))
        using (var brush = new SolidBrush(Color.FromArgb(180, Color.White))) {
            string guide = "ドラッグして範囲を選択　|　ESC でキャンセル";
            SizeF sz = e.Graphics.MeasureString(guide, font);
            e.Graphics.DrawString(guide, font, brush, (this.Width - sz.Width) / 2, 20);
        }
    }
}
"@ -ReferencedAssemblies System.Windows.Forms, System.Drawing

function Take-Screenshot {
    param([string]$SavePath)

    # スクリーン全体を一時キャプチャ
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
    $graphics.Dispose()

    # 選択フォーム表示
    $form = New-Object SelectionForm
    [System.Windows.Forms.Application]::Run($form)

    if ($form.Confirmed) {
        $region = $form.SelectedRegion
        $cropped = New-Object System.Drawing.Bitmap($region.Width, $region.Height)
        $g = [System.Drawing.Graphics]::FromImage($cropped)
        $g.DrawImage($bitmap, 0, 0, $region, [System.Drawing.GraphicsUnit]::Pixel)
        $g.Dispose()
        $bitmap.Dispose()

        # 保存先決定
        if (-not $SavePath) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $desktop = "C:\Users\ryoko\Desktop\スクリーンショト"
            if (-not (Test-Path $desktop)) { New-Item -ItemType Directory -Path $desktop | Out-Null }
            $SavePath = Join-Path $desktop "screenshot_$timestamp.png"
        }
        $cropped.Save($SavePath, [System.Drawing.Imaging.ImageFormat]::Png)
        $cropped.Dispose()

        # 通知
        $notify = New-Object System.Windows.Forms.NotifyIcon
        $notify.Icon = [System.Drawing.SystemIcons]::Information
        $notify.Visible = $true
        $notify.BalloonTipTitle = "スクリーンショット保存"
        $notify.BalloonTipText = "保存先: $SavePath"
        $notify.ShowBalloonTip(3000)
        Start-Sleep -Milliseconds 3500
        $notify.Dispose()

        Write-Host "保存しました: $SavePath" -ForegroundColor Green
    } else {
        $bitmap.Dispose()
        Write-Host "キャンセルしました" -ForegroundColor Yellow
    }
}

Take-Screenshot
