using CadParcial2Jcf;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClnParcial2Jcf
{
    public class ProgramaCln
    {
        public static int insertar(Programa programa)
        {
            using (var context = new Parcial2JcfEntities())
            {
                context.Programa.Add(programa);
                context.SaveChanges();
                return programa.id;
            }
        }

        public static int actualizar(Programa programa)
        {
            using (var context = new Parcial2JcfEntities())
            {
                var existingPrograma = context.Programa.Find(programa.id);
                    existingPrograma.descripcion = programa.descripcion;
                    existingPrograma.duracion = programa.duracion;
                    existingPrograma.fechaEstreno = programa.fechaEstreno;
                    existingPrograma.idCanal = programa.idCanal;
                    context.SaveChanges();
                    return existingPrograma.id;
            }
        }

        public static int eliminar(int id, DateTime fechaEstreno)
        {
            using (var context = new Parcial2JcfEntities())
            {
                var existe = context.Programa.Find(id);
                if (existe != null)
                {
                    existe.estado = -1;
                    existe.fechaEstreno = fechaEstreno;
                    context.SaveChanges();
                    return existe.id;
                }
                else
                {
                    throw new Exception("Programa no encontrado");
                }
            }
        }

        public static Programa obtenerUno(int id)
        {
            using (var context = new Parcial2JcfEntities())
            {
                return context.Programa.Find(id);
            }
        }

        public static List<paProgramaListar_Result> listar(string parametro)
        {
            using (var context = new Parcial2JcfEntities())
            {
                return context.Database.SqlQuery<paProgramaListar_Result>(
                    "EXEC paProgramaListar @parametro",
                    new SqlParameter("@parametro", parametro)
                ).ToList();
            }
        }
        public class paProgramaListar_Result
        {
            public int id { get; set; }
            public string titulo { get; set; }
            public string descripcion { get; set; }
            public int duracion { get; set; }
            public string productor { get; set; }
            public DateTime fechaEstreno { get; set; }
            public int idCanal { get; set; }
            public string nombreCanal { get; set; }
            public short estado { get; set; }
        }
        

        /*
        public static List<paProgramaListar_Result> listarPo(string parametro)
        {
            using (var context = new Parcial2JcfEntities())
            {
                return context.paProgramaListar(parametro).ToList();
            }
        }*/
    }
}
