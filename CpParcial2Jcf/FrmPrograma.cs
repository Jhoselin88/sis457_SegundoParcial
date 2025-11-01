using ClnParcial2Jcf;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace CpParcial2Jcf
{
    public partial class FrmPrograma : Form
    {
        private bool esNuevo = true;
        public FrmPrograma()
        {
            InitializeComponent();
        }
        private void listar()
        {
            var lista = ProgramaCln.listar(txtParametro.Text.Trim());
            dgvLista.DataSource = lista;
            dgvLista.Columns["id"].Visible = false;
            dgvLista.Columns["titulo"].HeaderText = "TITULO";
            dgvLista.Columns["descripcion"].HeaderText = "DESCRIPCION";
            dgvLista.Columns["productor"].HeaderText = "PRODUCTOR";
            dgvLista.Columns["fechaEstreno"].HeaderText = "FECHA ESTRENO";
            dgvLista.Columns["estado"].Visible = false;

            if (lista.Count > 0)
            {
                dgvLista.Rows[0].Selected = true;
            }
        }
        private void FrmPrograma_Load(object sender, EventArgs e)
        {
            listar();
        }

        private void btnNuevo_Click(object sender, EventArgs e)
        {
            esNuevo = true;
            txtDescripcion.Clear();
        }

        private void btnEditar_Click(object sender, EventArgs e)
        {
            esNuevo = false;

        }
    }
}
