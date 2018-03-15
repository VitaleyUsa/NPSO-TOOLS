using System;
using System.Security.Cryptography;
using System.Security.Permissions;
using System.IO;
using System.Security.Cryptography.X509Certificates;
using System.ServiceProcess;
using System.Management;

namespace RemoveExpCerts
{
    class Program
    {
        static void Main(string[] args)
        {
            int count = 0;

            // Меняем тип запуска на "Ручной" для службы распространения сертификатов
            DisableTheService("CertPropSvc");
            // Останавливаем службу распространения сертификатов
            ServiceController sc = new ServiceController("CertPropSvc");

            try { sc.Stop(); }
            catch {  }

            // Удаляем старые сертификаты
            X509Store store = new X509Store("My", StoreLocation.CurrentUser); // Открываем хранилище сертификатов у текущего пользователя
            store.Open(OpenFlags.ReadWrite | OpenFlags.OpenExistingOnly); // Даем права на изменение хранилища

            X509Certificate2Collection col = store.Certificates.Find(X509FindType.FindByTimeExpired, DateTime.Now, false); // Находим сертификаты только с истекщим сроком
            foreach (var cert in col) // Для каждого сертификата с истекщим сроком делаем
            {
                count++;
                store.Remove(cert); // удаление сертификата из хранилища
            }
            Console.WriteLine("Removed " + count + " certs");
            System.Threading.Thread.Sleep(3000);
            store.Close();
        }
        public static void DisableTheService(string serviceName)
        {
            using (var mo = new ManagementObject(string.Format("Win32_Service.Name=\"{0}\"", serviceName)))
            {
                mo.InvokeMethod("ChangeStartMode", new object[] { "Manual" });
            }
        }
    }
}
