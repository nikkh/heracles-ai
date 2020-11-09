using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Chania.Controllers
{

    [AllowAnonymous]
        public class AccountController : Controller
        {
            [HttpGet]
            public IActionResult SignOut(string page)
            {
                return RedirectToAction("Index", "Home");
            }
        }
    
}
