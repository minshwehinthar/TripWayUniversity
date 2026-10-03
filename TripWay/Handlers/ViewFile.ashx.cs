using System;
using System.IO;
using System.Web;

namespace TripWay.Handlers
{
    public class ViewFile : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            string f = context.Request.QueryString["f"];
            if (string.IsNullOrWhiteSpace(f))
            {
                context.Response.StatusCode = 400;
                context.Response.End();
                return;
            }

            f = f.Replace('\\', '/').TrimStart('/');
            if (f.StartsWith("~/", StringComparison.OrdinalIgnoreCase)) f = f.Substring(2);
            if (f.StartsWith("Uploads/", StringComparison.OrdinalIgnoreCase)) f = f.Substring("Uploads/".Length);

            string baseDir = context.Server.MapPath("~/Uploads");
            string baseFull = Path.GetFullPath(baseDir).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            string path = Path.GetFullPath(Path.Combine(baseDir, f));

            if (!path.StartsWith(baseFull, StringComparison.OrdinalIgnoreCase) || !File.Exists(path))
            {
                context.Response.StatusCode = 404;
                context.Response.End();
                return;
            }

            string name = Path.GetFileName(path);
            context.Response.ContentType = GetContentType(Path.GetExtension(path));
            context.Response.AppendHeader("Content-Disposition", "inline; filename=\"" + name + "\"");
            context.Response.TransmitFile(path);
            context.Response.End();
        }

        private static string GetContentType(string ext)
        {
            switch ((ext ?? "").ToLowerInvariant())
            {
                case ".pdf": return "application/pdf";
                case ".jpg":
                case ".jpeg": return "image/jpeg";
                case ".png": return "image/png";
                case ".gif": return "image/gif";
                case ".webp": return "image/webp";
                case ".txt": return "text/plain";
                default: return "application/octet-stream";
            }
        }

        public bool IsReusable { get { return false; } }
    }
}