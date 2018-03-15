using System;
using System.Security.Cryptography;
using System.Security.Permissions;
using System.IO;
using System.Security.Cryptography.X509Certificates;


namespace PRKD
{
    class Program
    {
        static void Main(string[] args)
        {
            X509Store store = new X509Store("REQUEST", StoreLocation.CurrentUser);
            store.Open(OpenFlags.ReadWrite | OpenFlags.OpenExistingOnly);

            X509Certificate2Collection collection = (X509Certificate2Collection)store.Certificates;
            foreach (X509Certificate2 x509 in collection)
            {
                try
                {
                    string name = x509.GetNameInfo(X509NameType.SimpleName, false);
                    string test = "Работник нотариальной конторы";

                    if (string.Equals(name, test))
                    {
                        X509Store store0 = new X509Store("Root", StoreLocation.LocalMachine);
                        store0.Open(OpenFlags.ReadWrite | OpenFlags.OpenExistingOnly);
                        store0.Add(x509);
                        store0.Close();

                        X509Store store1 = new X509Store("My", StoreLocation.CurrentUser);
                        store1.Open(OpenFlags.ReadWrite | OpenFlags.OpenExistingOnly);
                        store1.Add(x509);
                        store1.Close();
                    }

                    x509.Reset();
                }
                catch (CryptographicException)
                {
                    Console.WriteLine("Information could not be written out for this certificate.");
                }
            }
            store.Close();
        }
    }
}
