using System.Collections.Generic;

namespace Chania.Models
{
    public class IndexViewModel
    {
        public IndexViewModel() 
        {
            Signs = new Dictionary<string, SignPartialViewModel>();
        }
        public Dictionary<string, SignPartialViewModel> Signs { get; set; }
        
    }
}
