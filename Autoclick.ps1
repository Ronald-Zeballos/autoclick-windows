param([switch]$ValidateOnly)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$source = @'
using System;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace Autoclick {
    public class MainWindow : Form {
        [DllImport("user32.dll", SetLastError=true)]
        static extern bool RegisterHotKey(IntPtr handle, int id, uint modifiers, uint key);
        [DllImport("user32.dll")]
        static extern bool UnregisterHotKey(IntPtr handle, int id);
        [DllImport("user32.dll")]
        static extern void mouse_event(uint flags, uint x, uint y, uint data, UIntPtr extra);

        readonly NumericUpDown interval = new NumericUpDown();
        readonly NumericUpDown delay = new NumericUpDown();
        readonly ComboBox button = new ComboBox();
        readonly Button start = new Button();
        readonly Button stop = new Button();
        readonly Label status = new Label();
        readonly Label counter = new Label();
        readonly Label shortcut = new Label();
        readonly System.Windows.Forms.Timer timer = new System.Windows.Forms.Timer();
        readonly Stopwatch watch = new Stopwatch();
        Point anchor;
        bool countingDown, running, hotkey;
        double nextClick, period, countdownMs;
        long clicks;

        public MainWindow() {
            Text = "Autoclick - detener al mover el mouse";
            ClientSize = new Size(470, 365);
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            StartPosition = FormStartPosition.CenterScreen;
            AutoScaleMode = AutoScaleMode.Dpi;
            Font = new Font("Segoe UI", 10);
            BackColor = Color.FromArgb(245,247,250);

            Label heading = new Label {Text="Autoclick configurable", Left=24, Top=18,
                Width=420, Height=32, Font=new Font("Segoe UI", 16, FontStyle.Bold)};
            Controls.Add(heading);
            AddLabel("Intervalo entre clics (segundos)", 65);
            interval.SetBounds(320, 62, 120, 28);
            interval.DecimalPlaces=2; interval.Increment=0.1M;
            interval.Minimum=0.1M; interval.Maximum=3600; interval.Value=1;
            Controls.Add(interval);
            AddLabel("Tiempo para ubicar el mouse (seg.)", 107);
            delay.SetBounds(320, 104, 120, 28);
            delay.Minimum=0; delay.Maximum=60; delay.Value=3;
            Controls.Add(delay);
            AddLabel("Boton del mouse", 149);
            button.SetBounds(320, 146, 120, 28);
            button.DropDownStyle=ComboBoxStyle.DropDownList;
            button.Items.AddRange(new object[]{"Izquierdo", "Derecho", "Central"});
            button.SelectedIndex=0; Controls.Add(button);
            Controls.Add(new Label {Text="Se detiene al detectar cualquier movimiento del mouse.",
                Left=24, Top=191, Width=425, Height=25});
            start.Text="Iniciar (F8)"; start.SetBounds(24,225,200,38);
            start.Click += delegate { StartClicking(); }; Controls.Add(start);
            stop.Text="Detener (F8)"; stop.SetBounds(240,225,200,38);
            stop.Enabled=false;
            stop.Click += delegate { StopClicking("Detenido manualmente"); };
            Controls.Add(stop);
            status.SetBounds(24,277,420,25); status.Text="Listo. Intervalo inicial: 1 segundo.";
            status.ForeColor=Color.FromArgb(30,90,65); Controls.Add(status);
            counter.SetBounds(24,305,420,23); counter.Text="Clics: 0"; Controls.Add(counter);
            shortcut.SetBounds(24,333,425,24); Controls.Add(shortcut);
            timer.Interval=20; timer.Tick += OnTick;
        }
        void AddLabel(string text, int y) {
            Controls.Add(new Label {Text=text, Left=24, Top=y, Width=295, Height=28});
        }
        protected override void OnHandleCreated(EventArgs e) {
            base.OnHandleCreated(e);
            hotkey=RegisterHotKey(Handle,1,0x4000,0x77);
            shortcut.Text=hotkey ? "F8 global: iniciar / detener. Cerrar tambien detiene." :
                "F8 no disponible; usa los botones de la ventana.";
        }
        protected override void OnHandleDestroyed(EventArgs e) {
            if(hotkey) UnregisterHotKey(Handle,1);
            hotkey=false;
            base.OnHandleDestroyed(e);
        }
        protected override void WndProc(ref Message message) {
            if(message.Msg==0x0312 && message.WParam.ToInt32()==1) {
                if(running || countingDown) StopClicking("Detenido con F8");
                else StartClicking();
            }
            base.WndProc(ref message);
        }
        void StartClicking() {
            if(running || countingDown) return;
            clicks=0; counter.Text="Clics: 0";
            period=(double)interval.Value*1000;
            countdownMs=(double)delay.Value*1000;
            interval.Enabled=delay.Enabled=button.Enabled=start.Enabled=false;
            stop.Enabled=true;
            countingDown=true; watch.Restart();
            status.Text="Preparando: ubica el mouse...";
            timer.Start();
        }
        void StopClicking(string reason) {
            timer.Stop(); watch.Stop(); running=countingDown=false;
            interval.Enabled=delay.Enabled=button.Enabled=start.Enabled=true;
            stop.Enabled=false; status.Text=reason;
        }
        void OnTick(object sender, EventArgs e) {
            if(countingDown) {
                double remaining=countdownMs-watch.Elapsed.TotalMilliseconds;
                if(remaining>0) {
                    status.Text="Ubica el mouse: " + Math.Ceiling(remaining/1000) + " s";
                    return;
                }
                anchor=Cursor.Position;
                countingDown=false; running=true; watch.Restart();
                nextClick=period;
                status.Text="Activo. Mueve el mouse para detener.";
            }
            if(!running) return;
            if(Cursor.Position!=anchor) {
                StopClicking("Detenido: se movio el mouse.");
                return;
            }
            if(watch.Elapsed.TotalMilliseconds<nextClick) return;
            // Check again immediately before injecting a complete down/up pair.
            if(Cursor.Position!=anchor) {
                StopClicking("Detenido: se movio el mouse."); return;
            }
            uint flags=button.SelectedIndex==1 ? 0x0018u :
                button.SelectedIndex==2 ? 0x0060u : 0x0006u;
            mouse_event(flags,0,0,0,UIntPtr.Zero);
            clicks++; counter.Text="Clics: " + clicks;
            // No bursts of delayed clicks if the computer was busy.
            nextClick=watch.Elapsed.TotalMilliseconds+period;
        }
        protected override void OnFormClosed(FormClosedEventArgs e) {
            timer.Stop(); timer.Dispose(); watch.Stop();
            base.OnFormClosed(e);
        }
    }
    public static class Program {
        [STAThread]
        public static void Run() {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainWindow());
        }
    }
}
'@
try {
    Add-Type -TypeDefinition $source -ReferencedAssemblies System.Windows.Forms,System.Drawing
    if ($ValidateOnly) { Write-Output 'OK: codigo compilado.'; exit 0 }
    [Autoclick.Program]::Run()
} catch {
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Error de Autoclick') | Out-Null
    exit 1
}
