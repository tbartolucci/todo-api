using Microsoft.AspNetCore.Mvc;

namespace TodoApi.Controllers
{
	/// <inheritdoc />
	/// <summary>
	/// up check endpoint
	/// </summary>
    [Produces("application/json")]
    [Route("/api/todo/v1/[controller]")]
    [ApiExplorerSettings(GroupName = "v1")]
    public class UpController : Controller
    {
        /// <summary>
        /// Simply return a 200 without doing anything at all!
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public virtual IActionResult Up()
        {
            return Ok();
        }
    }
}
