using System;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32;

namespace EisLocation
{

    internal static class Program
    {
        [STAThread]
        static void Main()
        {
            Console.WriteLine("KLEIS Server Location = " + FindKLEISLocation(@"{02FFDDB1-4094-4434-879A-70AC8870FCCE}"));
            Console.WriteLine("KLEIS Client Location = " + FindKLEISLocation(@"{8D3AE984-6874-4C08-BA11-04A78154F17F}"));
            Console.WriteLine("EIS Location = " + FindEISLocation());
            Console.ReadKey();
        }

        private static string FindEISLocation()
        {
            // Enot location from registry
            var InstallPath = Environment.Is64BitOperatingSystem ? Registry.GetValue(@"HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\eNot_is1", "Inno Setup: App Path", null) : Registry.GetValue(@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\eNot_is1", "Inno Setup: App Path", null);

            // Case of enot location not found in registry
            return InstallPath == null ? @"C:\Triasoft\eNot" : InstallPath.ToString();
        }

        private static string FindKLEISLocation(string upgradeCode)
        {
            StringBuilder sbProductCode = new StringBuilder(39);
            StringBuilder sbInstallLocation = new StringBuilder();
            var installLocation = "";

            for (int iProductIndex = 0; ; iProductIndex++)
            {
                int iRes = NativeMethods.MsiEnumRelatedProducts(upgradeCode, 0, iProductIndex, sbProductCode);
                if (iRes != NativeMethods.NoError)
                {
                    // NativeMethods.ErrorNoMoreItems=259
                    break;
                }
                string productCode = sbProductCode.ToString();

                GetProperty(productCode, "InstallLocation", sbInstallLocation);
                installLocation = sbInstallLocation.ToString();
            }

            return installLocation;
        }

        private static int GetProperty(string productCode, string propertyName, StringBuilder sbBuffer)
        {
            int len = sbBuffer.Capacity;
            sbBuffer.Length = 0;
            int status = NativeMethods.MsiGetProductInfo(productCode,
                                                          propertyName,
                                                          sbBuffer, ref len);
            if (status == NativeMethods.ErrorMoreData)
            {
                len++;
                sbBuffer.EnsureCapacity(len);
                status = NativeMethods.MsiGetProductInfo(productCode, propertyName, sbBuffer, ref len);
            }
            if ((status == NativeMethods.ErrorUnknownProduct ||
                 status == NativeMethods.ErrorUnknownProperty)
                && (String.Compare(propertyName, "ProductVersion", StringComparison.Ordinal) == 0 ||
                    String.Compare(propertyName, "ProductName", StringComparison.Ordinal) == 0))
            {
                // try to get version manually
                StringBuilder sbKeyName = new StringBuilder();
                sbKeyName.Append("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Installer\\UserData\\S-1-5-18\\Products\\");
                Guid guid = new Guid(productCode);
                byte[] buidAsBytes = guid.ToByteArray();
                foreach (byte b in buidAsBytes)
                {
                    int by = ((b & 0xf) << 4) + ((b & 0xf0) >> 4);  // swap hex digits in the byte
                    sbKeyName.AppendFormat("{0:X2}", by);
                }
                sbKeyName.Append("\\InstallProperties");
                RegistryKey key = Registry.LocalMachine.OpenSubKey(sbKeyName.ToString());
                if (key != null)
                {
                    string valueName = "DisplayName";
                    if (String.Compare(propertyName, "ProductVersion", StringComparison.Ordinal) == 0)
                        valueName = "DisplayVersion";
                    string val = key.GetValue(valueName) as string;
                    if (!String.IsNullOrEmpty(val))
                    {
                        sbBuffer.Length = 0;
                        sbBuffer.Append(val);
                        status = NativeMethods.NoError;
                    }
                }
            }

            return status;
        }
    }

    // For Win32 MsiEnumRelatedProducts
    internal static class NativeMethods
    {
        #region Internal Fields

        internal const int ErrorMoreData = 234;
        internal const int ErrorNoMoreItems = 259;
        internal const int ErrorUnknownProduct = 1605;
        internal const int ErrorUnknownProperty = 1608;
        internal const int MaxGuidChars = 38;
        internal const int NoError = 0;

        #endregion Internal Fields

        #region Internal Methods

        [DllImport("msi.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        internal static extern int MsiEnumRelatedProducts(string lpUpgradeCode, int dwReserved,
            int iProductIndex, //The zero-based index into the registered products.
            StringBuilder lpProductBuf); // A buffer to receive the product code GUID.

        // This buffer must be 39 characters long. The first 38 characters are for the GUID, and
        // the last character is for the terminating null character.

        [DllImport("msi.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        internal static extern Int32 MsiGetProductInfo(string product, string property,
            StringBuilder valueBuf, ref Int32 cchValueBuf);

        #endregion Internal Methods
    }


    
}
