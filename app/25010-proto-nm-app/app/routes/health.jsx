export const loader = async ({ request }) => {
  return null;
};

export default function healthCheck (request, response) {
  new Response(null, {
    status: 200,
    statusText: "ok",
  });
}
