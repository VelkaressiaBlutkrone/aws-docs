import "./styles.css";
import {
  certificationLevels,
  certifications,
  officialSources,
  recommendedPaths,
  type Certification,
  type Level,
} from "./data";

const app = document.querySelector<HTMLDivElement>("#app");
const heroImageUrl = `${import.meta.env.BASE_URL}hero-roadmap.png`;

if (!app) {
  throw new Error("App root was not found.");
}

const levelLabels: Record<Level, string> = {
  Foundational: "Foundational 입문",
  Associate: "Associate 실무 기초~중급",
  Professional: "Professional 고급",
  Specialty: "Specialty 전문 분야",
};

const renderList = (items: string[]) =>
  items.map((item) => `<li>${item}</li>`).join("");

const renderCertCard = (cert: Certification) => `
  <article class="cert-card" id="${cert.id}">
    <div class="cert-card__top">
      <span class="level">${cert.level}</span>
      ${cert.code ? `<span class="code">${cert.code}</span>` : ""}
    </div>
    <h3>${cert.title}</h3>
    <p>${cert.audience}</p>
    <div class="chips">
      ${cert.focus.map((item) => `<span>${item}</span>`).join("")}
    </div>
    <a class="text-link" href="#roadmap-${cert.id}">로드맵 보기</a>
  </article>
`;

const renderLevelSection = (level: Level) => {
  const items = certifications.filter((cert) => cert.level === level);

  return `
    <section class="band" aria-labelledby="level-${level}">
      <div class="section-head">
        <h2 id="level-${level}">${levelLabels[level]}</h2>
        <span>${items.length}개 자격증</span>
      </div>
      <div class="cert-grid">
        ${items.map(renderCertCard).join("")}
      </div>
    </section>
  `;
};

const renderRoadmap = (cert: Certification) => `
  <article class="roadmap-item" id="roadmap-${cert.id}">
    <div>
      <span class="code">${cert.code ?? cert.level}</span>
      <h3>${cert.title}</h3>
      <p>${cert.audience}</p>
    </div>
    <ol>${renderList(cert.roadmap)}</ol>
  </article>
`;

const renderStudyDocs = (cert: Certification) => `
  <article class="doc-group">
    <h3>${cert.title}</h3>
    ${cert.studyDocs
      .map(
        (doc) => `
          <section class="doc-item">
            <h4>${doc.title}</h4>
            <p>${doc.outcome}</p>
            <ul>${renderList(doc.topics)}</ul>
          </section>
        `,
      )
      .join("")}
  </article>
`;

const renderPracticeExams = (cert: Certification) => `
  <article class="exam-group">
    <h3>${cert.title}</h3>
    <div class="exam-list">
      ${cert.exams
        .map(
          (exam) => `
            <section class="exam-item">
              <div>
                <h4>${exam.title}</h4>
                <p>${exam.scenario}</p>
              </div>
              <ul>${renderList(exam.checks)}</ul>
            </section>
          `,
        )
        .join("")}
    </div>
  </article>
`;

app.innerHTML = `
  <header class="site-header">
    <nav class="nav" aria-label="주요 메뉴">
      <a href="#top" class="brand">AWS Docs Roadmap</a>
      <div>
        <a href="#levels">단계</a>
        <a href="#paths">추천 순서</a>
        <a href="#roadmaps">로드맵</a>
        <a href="#docs">학습 문서</a>
        <a href="#exams">모의고사</a>
      </div>
    </nav>
  </header>

  <main id="top">
    <section class="hero">
      <div class="hero__content">
        <span class="eyebrow">AWS 공식 시험 가이드 기준</span>
        <h1>AWS Certification Study Roadmap</h1>
        <p>
          입문부터 전문 분야까지 자격증 단계, 추천 순서, 상세 학습 문서,
          모의고사 회차를 한 곳에서 관리하는 GitHub Pages 문서 사이트입니다.
        </p>
        <div class="hero__actions">
          <a class="button" href="#paths">추천 순서 보기</a>
          <a class="button button--secondary" href="#exams">모의고사 구성</a>
        </div>
      </div>
      <aside class="hero__visual" aria-label="AWS 자격증 학습 이미지">
        <img src="${heroImageUrl}" alt="클라우드 자격증 학습 워크스페이스" />
        <div>
          <strong>GitHub Pages</strong>
          <span>VelkaressiaBlutkrone/aws-docs</span>
          <span>Base path: /aws-docs/</span>
        </div>
      </aside>
    </section>

    <section class="sources" aria-label="공식 출처">
      ${officialSources
        .map(
          (source) =>
            `<a href="${source.href}" target="_blank" rel="noreferrer">${source.title}</a>`,
        )
        .join("")}
    </section>

    <div id="levels">
      ${certificationLevels.map(renderLevelSection).join("")}
    </div>

    <section class="band" id="paths" aria-labelledby="paths-title">
      <div class="section-head">
        <h2 id="paths-title">추천 순서</h2>
        <span>목표별 기본 경로</span>
      </div>
      <div class="path-grid">
        ${recommendedPaths
          .map(
            (path) => `
              <article class="path-card">
                <h3>${path.title}</h3>
                <p>${path.steps.join(" -> ")}</p>
              </article>
            `,
          )
          .join("")}
      </div>
    </section>

    <section class="band" id="roadmaps" aria-labelledby="roadmaps-title">
      <div class="section-head">
        <h2 id="roadmaps-title">자격증별 학습 로드맵</h2>
        <span>${certifications.length}개 로드맵</span>
      </div>
      <div class="stack">
        ${certifications.map(renderRoadmap).join("")}
      </div>
    </section>

    <section class="band" id="docs" aria-labelledby="docs-title">
      <div class="section-head">
        <h2 id="docs-title">상세 학습 문서</h2>
        <span>문서 단위 학습 목표</span>
      </div>
      <div class="doc-grid">
        ${certifications.map(renderStudyDocs).join("")}
      </div>
    </section>

    <section class="band" id="exams" aria-labelledby="exams-title">
      <div class="section-head">
        <h2 id="exams-title">학습 문서 기반 모의고사</h2>
        <span>자격증별 6회차 구성</span>
      </div>
      <div class="exam-grid">
        ${certifications.map(renderPracticeExams).join("")}
      </div>
    </section>
  </main>

  <footer class="footer">
    <p>Unofficial study site. Use AWS official exam guides as the source of truth before scheduling an exam.</p>
  </footer>
`;
