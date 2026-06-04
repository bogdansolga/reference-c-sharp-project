/**
 * Product response shape returned by the C# API (GET /api/v1/product).
 * Mirrors the api Dtos/ProductResponse. Request validation lives server-side
 * (FluentValidation), so the frontend only needs the response type.
 */
export interface ProductResponse {
  id: number;
  name: string;
  price: number;
  sectionId: number;
}
