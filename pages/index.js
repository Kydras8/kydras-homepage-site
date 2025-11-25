import Image from "next/image";

export default function Home() {
  return (
    <main
      style={{
        background: "#0a0a0f",
        color: "#d4af37",
        minHeight: "100vh",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        textAlign: "center",
        padding: "40px"
      }}
    >
      <Image
        src="/kydras-logo.png"
        alt="Kydras Systems Logo"
        width={320}
        height={320}
        priority
        style={{ marginBottom: "24px" }}
      />
      <h1
        style={{
          fontSize: "3rem",
          marginBottom: "8px",
          letterSpacing: "0.12em"
        }}
      >
        KYDRAS SYSTEMS INC.
      </h1>
      <h2
        style={{
          fontSize: "1.4rem",
          fontWeight: 300,
          opacity: 0.9
        }}
      >
        NOTHING IS OFF LIMITS
      </h2>
    </main>
  );
}
