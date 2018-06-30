using System;
using Microsoft.AspNetCore.Mvc;

namespace TodoApi.Controllers
{
	/// <inheritdoc />
	/// <summary>
	/// </summary>
    [Produces("application/json")]
    [Route("/api/todo/v1/[controller]")]
    [ApiExplorerSettings(GroupName = "v1")]
    public class HealthController : Controller
    {
		/// <summary>
		/// Performs a lightweight health check of key dependencies
		/// </summary>
		/// <returns>The application's health status</returns>
        [HttpGet]
        public virtual IActionResult Healthcheck()
        {
            // TODO: simple, lightweight, idempotent check of main dependency
            bool ok = true;

            var result = new ContentResult();
            result.StatusCode = ok ? 200 : 500;
            result.Content = $"{(ok ? "HEALTHY" : "NOT HEALTHY")} - {DateTime.Now.ToString("O")}";
            return result;
        }
    }
}
