using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace DSCMonitoring.Models
{
    public class DSCNode
    {
        [Key]
        public string NodeName { get; set; }
        public string Status { get; set; }
        public string HostName { get; set; }
       
    }
}
