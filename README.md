# Autoclick para Windows

Autoclick con interfaz gráfica en español. Hace un clic cada segundo de forma predeterminada y se detiene cuando detecta que moviste el mouse.

## Requisitos

- Windows 10 u 11 con escritorio gráfico.
- Windows PowerShell 5.1 y .NET Framework, incluidos normalmente en Windows.
- No requiere Python, Node.js, paquetes adicionales ni permisos de administrador.

## Descargar e instalar

1. En este repositorio, selecciona **Code → Download ZIP**.
2. Extrae el ZIP completo en una carpeta. No ejecutes los archivos directamente dentro del ZIP.
3. Haz doble clic en **Instalar.cmd**.
4. El instalador copia la aplicación a `%LOCALAPPDATA%\Autoclick` y crea un acceso directo **Autoclick** en tu escritorio.
5. Abre el acceso directo. El programa queda esperando que presiones **Iniciar** o **F8**.

El instalador funciona para tu usuario y no agrega la aplicación al inicio de Windows. Puedes volver a ejecutarlo para actualizar la copia instalada. Los valores se restablecen al cerrar la aplicación.

### Usarlo sin instalar

Después de extraer el ZIP, abre **Abrir Autoclick.vbs**. Si Windows tiene deshabilitado VBScript, usa **Abrir Autoclick.cmd**.

También puedes ejecutarlo desde Windows PowerShell en la carpeta descargada:

```powershell
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File .\Autoclick.ps1
```

`-ExecutionPolicy Bypass` se aplica únicamente al proceso que abre la aplicación; no cambia la configuración permanente de PowerShell. Las políticas de una organización pueden impedir la ejecución.

## Uso

1. Elige el **intervalo entre clics**: de 0,10 a 3600 segundos. El valor inicial es **1 segundo**.
2. Configura el **tiempo para ubicar el mouse**: de 0 a 60 segundos. El valor inicial es **3 segundos**.
3. Elige el botón: **Izquierdo**, **Derecho** o **Central**.
4. Presiona **Iniciar** o **F8**. Durante la cuenta regresiva puedes mover el cursor hasta el lugar deseado.
5. Cuando termina la cuenta regresiva, deja el cursor quieto. El primer clic ocurre después del intervalo configurado.
6. Mueve el mouse para detener. Para volver a empezar, presiona **F8** o **Iniciar**.

| Acción | Control |
| --- | --- |
| Iniciar | Botón Iniciar o F8 |
| Detener durante los clics | Mover el mouse, F8 o botón Detener |
| Cancelar la cuenta regresiva | F8 o botón Detener |
| Salir | Cerrar la ventana |

**F8 es global**: funciona con otra ventana enfocada si ninguna otra aplicación reservó esa tecla. La ventana informa si el atajo no está disponible.

La detección de movimiento comienza al terminar la cuenta regresiva. El programa comprueba la posición del cursor aproximadamente cada 20 ms y se detiene cuando detecta un cambio. No se reactiva automáticamente. Windows puede retrasar los clics si el equipo está ocupado; no se acumulan ráfagas de clics atrasados.

## Desinstalar

Cierra Autoclick, elimina la carpeta `%LOCALAPPDATA%\Autoclick` y borra el acceso directo **Autoclick** del escritorio. Si usaste la versión sin instalar, basta con eliminar la carpeta extraída.

## Solución de problemas

- **No se abre con el archivo `.vbs`:** usa **Abrir Autoclick.cmd** para ejecutar sin VBScript y ver cualquier error.
- **No funciona F8:** revisa el mensaje al pie de la ventana. Cierra otras instancias de Autoclick o utiliza los botones.
- **Se detiene enseguida:** evita tocar el mouse después de la cuenta regresiva; el touchpad también puede mover el cursor. Aumenta la espera inicial si necesitas más tiempo.
- **No hace clic en una aplicación:** algunas aplicaciones bloquean clics simulados. Una aplicación ejecutada como administrador puede rechazar los clics de un proceso con permisos normales.
- **El equipo está administrado por una organización:** consulta con su administrador si una política bloquea PowerShell. El instalador no modifica esas políticas.

## Archivos y funcionamiento

| Archivo | Función |
| --- | --- |
| `Autoclick.ps1` | Interfaz de Windows Forms y lógica en C#, compilada en memoria al abrir |
| `Abrir Autoclick.vbs` | Abre la aplicación sin consola |
| `Abrir Autoclick.cmd` | Alternativa sin VBScript |
| `Instalar.cmd` | Inicia el instalador para el usuario actual |
| `Instalar.ps1` | Copia los archivos y crea el acceso directo |
| `LEEME.txt` | Guía breve sin conexión |

La aplicación utiliza funciones de Windows para enviar clics y registrar F8. No necesita conexión a Internet.

Para comprobar que el código de la aplicación compila sin iniciar los clics:

```powershell
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File .\Autoclick.ps1 -ValidateOnly
```
