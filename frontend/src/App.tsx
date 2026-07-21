import { BrowserRouter, Routes, Route } from "react-router-dom";
import AppShell from "./components/layout/AppShell";
import Home from "./pages/Home";
import BreederSimulator from "./modules/breeder/BreederSimulator";
import GeneLab from "./modules/genelab/GeneLab";
import GeneDetective from "./modules/detective/GeneDetective";
import ResearchSupervisor from "./modules/supervisor/ResearchSupervisor";
import VivaExaminer from "./modules/viva/VivaExaminer";
import GamesHub from "./modules/games/GamesHub";
import ResearchLab from "./modules/researchlab/ResearchLab";
import FieldNotebook from "./modules/notebook/FieldNotebook";
import CareerMode from "./modules/career/CareerMode";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<AppShell />}>
          <Route path="/" element={<Home />} />
          <Route path="/breeder" element={<BreederSimulator />} />
          <Route path="/gene-lab" element={<GeneLab />} />
          <Route path="/detective" element={<GeneDetective />} />
          <Route path="/supervisor" element={<ResearchSupervisor />} />
          <Route path="/viva" element={<VivaExaminer />} />
          <Route path="/games" element={<GamesHub />} />
          <Route path="/research-lab" element={<ResearchLab />} />
          <Route path="/notebook" element={<FieldNotebook />} />
          <Route path="/career" element={<CareerMode />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
