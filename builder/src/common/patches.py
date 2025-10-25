from typing import List
from pydantic import BaseModel, Field, model_validator


class Category(BaseModel):
    name: str = Field(..., description="Human-readable name of the category")
    excerpt: str = Field(..., description="Short summary of the category")
    description: str = Field(..., description="Detailed description of the category")


class Patch(BaseModel):
    file: str = Field(..., description="Patch filename (e.g. 'foo.patch')")
    name: str = Field(..., description="Display name for the patch")
    description: str = Field(..., description="Short patch description")
    reason: str = Field(..., description="Why this patch exists")
    effect: str = Field(..., description="What the patch changes")
    category: str = Field(
        ..., description="Category name (must match a category in the YAML)"
    )


class PatchConfig(BaseModel):
    categories: List[Category]
    patches: List[Patch]

    @model_validator(mode="after")
    def validate_patch_categories(self):
        """Ensure each patch.category matches a defined category name."""
        defined_cats = {c.name for c in self.categories}
        for p in self.patches:
            if p.category not in defined_cats:
                raise ValueError(
                    f"Patch '{p.name}' refers to unknown category '{p.category}'"
                )
        return self
