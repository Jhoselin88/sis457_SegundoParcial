using CadParcial2Jcf;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ClnParcial2Jcf
{
    public class ProgramaCln
    {
        public static int insertar(Programa pograma)
        {
            using (var context = new Parcial2JcfEntities())
            {
                context.Programa.Add(Programa);
                context.SaveChanges();
                return Programa.id;
            }
        }
        public static int actualizar(Programa programa) 
        {
            using (var context = new Parcial2JcfEntities())
            {
                var existe = context.Programa.Find(programa.id);
                existe.idCanal = programa.idCanal;
                existe.titulo = programa.titulo;
                existe.descripcion = programa.descripcion;
                existe.duracion = programa.duracion;
                existe.productor = programa.productor;
                existe.fechaEstreno = programa.fechaEstreno;
                existe.estado = programa.estado;
                existe.usuarioRegistro = programa.usuarioRegistro;
                return context.SaveChanges();
            }
        }
        public static int eliminar(int id, string usuarioRegistro)
        {
            using (var context = new Parcial2JcfEntities())
            {
                var existe = context.Programa.Find(id);
                existe.estadoRegistro = -1;
                existe.usuarioRegistro = usuarioRegistro;
                return context.SaveChanges();
            }
        }
        public static Programa obtenerUno(int id)
        {
            using (var context = new Parcial2JcfEntities())
            {
                return context.Programa.Find(id);
            }
        }
        public static List<Programa> listar()
        {
            using (var context = new Parcial2JcfEntities())
            {
                return context.Programa.Where(x => x.estadoRegistro != -1).ToList();
            }
        }

        public static List<paProgramaListar_Result> listarPa(string parametro)
        {
            using (var context = new Parcial2JcfEntities())
            {
                return context.paProgramaListar(parametro).ToList();
            }
        }
    }
}